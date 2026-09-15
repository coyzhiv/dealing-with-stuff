extends CanvasLayer

@onready var anim = $Control/AnimationPlayer
@onready var tranistion_sound = $"Audio/Переход"

@onready var alisa_points_label = $Control/ColorRect8/PointsLabel2
@onready var lina_points_label = $Control/ColorRect9/PointsLabel2
var follow_sprite

func play_battle_trans():
	anim.play("battle_transition")
	
func change_scene(file, pos, direction, location, sound_id):
	Globals.current_scene = file
	Globals.direction = direction
	Globals.location = location
	Globals.sound_id = sound_id
	get_tree().paused = true
	anim.play('simple_transition')
	await get_tree().create_timer(0.3).timeout
	tranistion_sound.play()
	get_tree().change_scene_to_file(file)
	await get_tree().create_timer(0.1).timeout
	
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	var follow = get_tree().get_root().find_child("Follow",true,false)
	if follow != null:
		follow_sprite = follow.find_child("Sprite3D",true,false)
	player.position = pos
	match direction:
			"up": 
				player_sprite.frame = 3
				if follow != null:
					follow.position = Vector3(pos.x, pos.y, pos.z + 0.1)
					follow_sprite.frame = 3
			"down": 
				player_sprite.frame = 0
				if follow != null:
					follow.position = Vector3(pos.x, pos.y, pos.z - 0.1)
					follow_sprite.frame = 0
			"left": 
				player_sprite.frame = 6
				if follow != null:
					follow.position = Vector3(pos.x + 0.1, pos.y, pos.z)
					follow_sprite.frame = 6
			"right": 
				player_sprite.frame = 9
				if follow != null:
					follow.position = Vector3(pos.x - 0.1, pos.y, pos.z)
					follow_sprite.frame = 9
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false

func load_save(file, pos, direction, location, sound_id, transition_status):
	Globals.current_scene = file
	Globals.direction = direction
	Globals.location = location
	Globals.sound_id = sound_id
	get_tree().paused = true
	if transition_status:
		anim.play("simple_transition")
		await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file(file)
	await get_tree().create_timer(0.1).timeout
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	var follow = get_tree().get_root().find_child("Follow",true,false)
	if follow != null:
		follow_sprite = follow.find_child("Sprite3D",true,false)
	player.position = pos
	match direction:
			"up": 
				player_sprite.frame = 3
			"down": 
				player_sprite.frame = 0
			"left": 
				player_sprite.frame = 6
			"right": 
				player_sprite.frame = 9
	if follow != null:
		follow.position = Globals.follow_pos
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false

func play_simple_transition(scale = 1.0):
	anim.play('simple_transition', -1, scale)

func play_battle_end_transiton(points_amount):
	$Control/ColorRect8/PointsLabel.text = tr("ALISA_RP")
	$Control/ColorRect9/PointsLabel.text = tr("LINA_RP")
	anim.play("battle_end_transition_start")
	var temp_points = 0
	alisa_points_label.text = str(Globals.alisa_points) + " (+0)"
	lina_points_label.text = str(Globals.lina_points) + " (+0)"
	await get_tree().create_timer(0.6).timeout
	for i in 20:
		temp_points += points_amount / 20;
		alisa_points_label.text = str(Globals.alisa_points + temp_points) + " (+" + str(temp_points) + ")"
		lina_points_label.text = str(Globals.lina_points + temp_points) + " (+" + str(temp_points) + ")"
		await get_tree().create_timer(0.03).timeout
	await get_tree().create_timer(1).timeout
	Globals.alisa_points += points_amount
	Globals.lina_points += points_amount
	anim.play_backwards("battle_end_transition_start")
