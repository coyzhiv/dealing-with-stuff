extends CanvasLayer

var is_dialogue_active: bool = false
var base_text_speed = 0.03
var text_speed = 0.03

var characters:Array [CharacterBody3D] = []
var character_sprites:Array

var cutscene_sprites: Array

var player
var player_sprite
var follow

@onready var left_portrait = $Portraits/LeftPortarit
@onready var right_portrait = $Portraits/RightPortrait
@onready var name_label = $NameLabel
@onready var text_label = $TextLabel
@onready var text_box = $DialogueBoxBig
@onready var item_icon = $ItemIcon
@onready var anim = $AnimationPlayer
@onready var anim2 = $AnimationPlayer2

@onready var test_enemy = preload("res://scenes/globals/fight_chars/test_fight_char.tres")
@onready var test_enemy_sprite = preload("res://resourses/sprites/enemies/trash_enemy.png")

@onready var dishes_enemy = preload("res://scenes/globals/fight_chars/dishes_fight_char.tres")
@onready var dishes_enemy_sprite = preload("res://resourses/sprites/enemies/enemy_dishes.png")

@onready var washing_machine_enemy = preload("res://scenes/globals/fight_chars/washing_machine_fight_char.tres")
@onready var washing_machine_enemy_sprite = preload("res://resourses/sprites/enemies/washing_machine_enemy.png")

@onready var trash_enemy = preload("res://scenes/globals/fight_chars/trash_fight_char.tres")
@onready var trash_enemy_sprite = preload("res://resourses/sprites/enemies/trash_enemy.png")

@onready var last_beer = preload("res://scenes/globals/items/last_beer.tres")


enum p
{
	left, right
}
signal confirm_pressed
signal skip_pressed
signal dialogue_started
signal dialogue_finished
signal text_finished
signal battle_over
signal wait_over
signal camera_moved

func _ready():
	characters.resize(5)
	character_sprites.resize(5)
	BattleScene.battle_over.connect(_on_battle_over_export)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("confirm") and is_dialogue_active:
		confirm_pressed.emit()
		text_speed = 0.005
		
		

func start(name: String):
	player = get_tree().get_root().find_child("Player",true, false)
	player_sprite = player.find_child("Sprite3D",true,false)
	player.anim.stop()
	match player.currentDirection:
		player.directions.UP: turn_player("up")
		player.directions.DOWN: turn_player("down")
		player.directions.LEFT: turn_player("left")
		player.directions.RIGHT: turn_player("right")
	text_box.position.y = 200
	text_box.visible = true
	var tween = create_tween()
	tween.tween_property(text_box, "position", Vector2(0, 0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	visible = true
	is_dialogue_active = true
	await tween.finished
	dialogue_started.emit()
	play_dialogue(name)
	
func easy_start(text: String):
	visible = true
	is_dialogue_active = true
	dialogue_started.emit()
	new_dialogue_window("", text, "", "left")
	await text_finished
	await confirm_pressed
	finish()

func finish():
	var tween = create_tween()
	tween.tween_property(text_box, "position", Vector2(0, 200), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	left_portrait.visible = false
	right_portrait.visible = false
	text_label.text = ""
	name_label.text = ""
	await tween.finished
	visible = false
	text_box.visible = false
	is_dialogue_active = false
	dialogue_finished.emit()


func play_dialogue(name):
	var file = FileAccess.open(name, FileAccess.READ)
	var json_text = JSON.parse_string(file.get_as_text())
	file.close()
	if json_text is not Dictionary:
		print("error creating dialogue")
		
	var dialogue_name = "dialogue"
	var next_prompt
	var skipping = false
	var in_else = false
	
	while dialogue_name != "end":
		for i in json_text[dialogue_name].size():
			
			var func_name = json_text[dialogue_name][i]["func"]
			var args = json_text[dialogue_name][i]["args"]
			
			if func_name == "if":
				var condition_result = evaluate_condition(args)
				if not condition_result:
					skipping = true
				in_else = false
				continue  

			if func_name == "else":
				if skipping:
					skipping = false
				else:
					skipping = true
				in_else = true
				continue

			if func_name == "endif":
				skipping = false
				in_else = false
				continue

			if skipping:
				continue
				
			if func_name == "wait":
				await get_tree().create_timer(args[0]).timeout
				continue
			
			next_prompt = callv(func_name, args)
			
			if func_name == "new_dialogue_window":
				await text_finished
				var tween1 = get_tree().create_tween()
				tween1.tween_property($ChangingKey, "modulate", Color(1.0, 1.0, 1.0), 0.1)
				await confirm_pressed
				var tween2 = get_tree().create_tween()
				tween2.tween_property($ChangingKey, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.1)
			elif func_name == "give_item":
				await text_finished
				await confirm_pressed
				item_icon.visible = false
			elif func_name == "move_camera":
				await camera_moved
			elif func_name == "relocate_camera":
				await camera_moved
			if func_name == "start_fight":
				new_dialogue_window("", "", "", "")
				await battle_over
			elif func_name == "player_walk":
				new_dialogue_window("", "", "", "")
				await player.cutscene_walk_ended
			elif func_name == "follow_walk":
				new_dialogue_window("", "", "", "")
				await follow.cutscene_walk_ended
			print(func_name, BattleScene.battle_lost)
			if func_name == "end_fight" and BattleScene.battle_lost:
				print("end emitted")
				dialogue_name = "end"
				BattleScene.battle_lost = true
				break
			
			
		if next_prompt != null:
			dialogue_name = next_prompt
		else:
			dialogue_name = "end"
		
		
	finish()

func quit():
	get_tree().quit()

func set_global(name, value):
	Globals.set(name, value)
	
func set_interaction_memory(name, value):
	InteractionMemory.set(name, value)

func set_value(name, value):
	set(name, value)
	
func play_soundtrack(location, variant):
	Soundtrack.play(location, variant)
	
func interaction_memory_after_battle(object_name, memory_cell):
	var object = get_tree().get_root().find_child(object_name,true,false)
	print("slow: ", BattleScene.slow_points, " fast: ", BattleScene.fast_points)
	if BattleScene.slow_points > BattleScene.fast_points:
		object.change_state(2)
		InteractionMemory.set(memory_cell, 2)
		return "ending1"
	else: 
		object.change_state(3)
		InteractionMemory.set(memory_cell, 3)
		return "ending2"

func change_cutscene_sprite(name, value):
	var cutscene_sprite = get_tree().get_root().find_child(name, true, false)
	cutscene_sprite.frame = value

func set_character(name, index):
	characters[index] = get_tree().get_root().find_child(name,true,false)
	character_sprites[index] = characters[index].find_child("Sprite3D",true,false)

func turn_player(direction):
	match direction:
		"down": player_sprite.frame = 0
		"up": player_sprite.frame = 3
		"left": player_sprite.frame = 6
		"right": player_sprite.frame = 9

func turn_character(index, direction):
	match direction:
		"down": character_sprites[index].frame = 0
		"up": character_sprites[index].frame = 3
		"left": character_sprites[index].frame = 6
		"right": character_sprites[index].frame = 9

func save():
	SaveAndLoad.save()

func relocate_character(index, x,y,z):
	characters[index].position = Vector3(x,y,z)

func relocate_player(x,y,z):
	player.position = Vector3(x,y,z)
	
func relocate_follow(x,y,z):
	follow.position = Vector3(x,y,z)

func play_transition():
	Transition.play_simple_transition()
	
func activate_follow():
	follow.activate()

func find_follow():
	follow = get_tree().get_root().find_child("Follow",true,false)

func deactivate_follow():
	follow.deactivate()

func player_walk(x, y, direction, lenght, duration):
	player.cutscene_walk(Vector2(x, y), direction, lenght, duration)

func player_visible(value):
	player.visible = value

func follow_walk(x, y, direction, lenght, duration):
	follow.cutscene_walk(Vector2(x, y), direction, lenght, duration)
	
func follow_visible(value):
	follow.visible = value

func move_camera(distance_x, distance_z, time):
	var camera = player.find_child("Camera3D", true, false)
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween1.tween_property(camera, "position:x", distance_x, time)
	tween2.tween_property(camera, "position:z", distance_z, time)
	await tween1.finished
	camera_moved.emit()
	
func cutscene_relocate_camera(pos_x, pos_y, pos_z, time):
	var camera = get_tree().get_root().find_child("CutsceneCamera3D", true, false)
	print(camera)
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "position", Vector3(pos_x, pos_y, pos_z), time)
	await tween.finished
	camera_moved.emit()

func evaluate_condition(args: Array) -> bool:
	if args.size() < 3:
		if args[1] == true or args[1] == false:
			if get_variable_value(args[0]) == args[1]:
				return true
			else:
				return false
		else:
			push_error("Invalid if condition format")
			return false

	var variable = args[0]
	var operator = args[1]
	var value = args[2]

	var current_value = get_variable_value(variable)

	match operator:
		"==":
			return current_value == value
		"!=":
			return current_value != value
		">":
			return current_value > value
		"<":
			return current_value < value
		">=":
			return current_value >= value
		"<=":
			return current_value <= value
		_:
			push_error("Unknown operator: " + operator)
			return false

func get_variable_value(path: String):
	if path.begins_with("InteractionMemory."):
		var var_name = path.replace("InteractionMemory.", "")
		return InteractionMemory.get(var_name)
	elif path.begins_with("Globals."):
		var var_name = path.replace("Globals.", "")
		return Globals.get(var_name)
	else:
		push_error("Unknown variable path: " + path)
		return null

func new_dialogue_window(name, text, portrait, portrait_place):
	print("ndw text: ", text)
	if name != "":
		write_name(name)
	else:
		write_name(name)
	write_text(text)
	
	if portrait != "":
		var portrait_sprite = get_tree().get_root().find_child(portrait,true,false)
		if portrait_place == "right":
			show_portrait(portrait_sprite, p.right)
		else:
			show_portrait(portrait_sprite, p.left)
	else:
		if portrait_place == "right":
			show_portrait(null, p.right)
		else:
			show_portrait(null, p.left)

func write_name(name:String):
	if name != "":
		name_label.text = name + ":"
	else:
		name_label.text = name
	
func write_text(text:String):
	await get_tree().create_timer(0.05).timeout
	text_speed = base_text_speed
	text_label.text = text
	text_label.visible_characters = 0
	for i in text_label.get_total_character_count():
		text_label.visible_characters += 1
		if text[i] == ".":
			await get_tree().create_timer(0.15).timeout
		await get_tree().create_timer(text_speed).timeout
		if not $Audio/DialogueSound.playing:
			$Audio/DialogueSound.pitch_scale = randf_range(0.9,1.2)
			$Audio/DialogueSound.play()
	text_speed = base_text_speed
	if text != "":
		text_finished.emit()

func show_portrait(portrait, portrait_place):
	if portrait != null:
		if portrait_place == p.left:
			left_portrait.visible = true
			left_portrait.texture = portrait.texture
			anim.play_backwards("fade_dark_left")
			anim.play("fade_dark_right")
			anim.play("bounce_left_portrait")
			
		
		if portrait_place == p.right:
			right_portrait.visible = true
			right_portrait.texture = portrait.texture
			anim.play_backwards("fade_dark_right")
			anim.play("fade_dark_left")
			anim.play("bounce_right_portrait")
	else:
		var tween1 = get_tree().create_tween()
		var tween2 = get_tree().create_tween()
		tween1.tween_property(left_portrait, "modulate", Color("#c0c0c0"), 0.1)
		tween2.tween_property(right_portrait, "modulate", Color("#c0c0c0"), 0.1)

func clear_portrait(place):
	if place == "left":
		left_portrait.visible = false
	if place == "right":
		right_portrait.visible = false

func give_item(text, item):
	var item_object
	match item:
		"last_beer": item_object = last_beer
	item_icon.visible = false
	item_icon.texture = item_object.icon
	anim2.play("new item")
	item_icon.visible = true
	Globals.inventory.append(item_object)
	print("give item text: ", text)
	new_dialogue_window("", text, "", null)

func start_fight(enemy_name, location, variant):
	var enemy
	var enemy_sprite
	visible = false
	is_dialogue_active = true
	Transition.play_battle_trans()
	Soundtrack.stop(location)
	match enemy_name:
		"dishes": 
			enemy = dishes_enemy 
			enemy_sprite = dishes_enemy_sprite
		"washing_machine": 
			enemy = washing_machine_enemy 
			enemy_sprite = washing_machine_enemy_sprite
		"trash": 
			enemy = trash_enemy 
			enemy_sprite = trash_enemy_sprite
	BattleScene.start(enemy, enemy_sprite)

func end_fight():
	visible = true
	is_dialogue_active = true

func _on_battle_over_export():
	battle_over.emit()

func play_sound(sound_name):
	match sound_name:
		"transition" : $Audio/TransitionSound.play()

func change_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)

func test_fight():
	start_fight(test_enemy, "apartament", 0)
	await battle_over
	Soundtrack.play("apartament", 0)
	finish()

func cant_leave_enter():
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	player_sprite.frame = 6
	new_dialogue_window("","You can't leave just now. You have things to do.","",p.left)
	await text_finished
	await confirm_pressed
	player.cutscene_walk(Vector2(1,0), "left", 0.2, 1)
	await player.cutscene_walk_ended
	finish()

func leave_enter():
	var player = get_tree().get_root().find_child("Player",true,false)
	var follow = get_tree().get_root().find_child("Follow",true,false)
	Transition.play_simple_transition()
	await get_tree().create_timer(0.5).timeout
	follow.global_position = player.global_position
	follow.global_position.x = player.global_position.x + 0.2
	await get_tree().create_timer(0.5).timeout
	player.visible = false
	$Audio/TransitionSound.play()
	await get_tree().create_timer(1).timeout
	follow.cutscene_walk(Vector2(-1,0), "left", 0.2, 1)
	await get_tree().create_timer(1).timeout
	follow.visible = false
	$Audio/TransitionSound.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	finish()
