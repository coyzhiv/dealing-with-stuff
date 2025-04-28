extends CanvasLayer

@export var fight_active = false

var current_turn

var alisa_skill_pool: Array[Skills]
var lina_skill_pool: Array[Skills]

var callable
var target

var alisa_base_spd 
var lina_base_spd 
var enemy_base_spd 
var enemy_base_hp

var queue: Array
var valid_targets: Array

var rng = RandomNumberGenerator.new()

enum directions
{
	UP, DOWN, LEFT, RIGHT
}
var alisa_current_direction
var lina_current_direction

@onready var alisa_skill_display_up = $SubViewportContainer/SubViewport/SkillsAlisa/Up
@onready var alisa_skill_display_down = $SubViewportContainer/SubViewport/SkillsAlisa/Down
@onready var alisa_skill_display_left = $SubViewportContainer/SubViewport/SkillsAlisa/Left
@onready var alisa_skill_display_right = $SubViewportContainer/SubViewport/SkillsAlisa/Right
@onready var lina_skill_display_up = $SubViewportContainer/SubViewport/SkillsLina/Up
@onready var lina_skill_display_down = $SubViewportContainer/SubViewport/SkillsLina/Down
@onready var lina_skill_display_left = $SubViewportContainer/SubViewport/SkillsLina/Left
@onready var lina_skill_display_right = $SubViewportContainer/SubViewport/SkillsLina/Right


var alisa_fight = preload("res://scenes/globals/fight_chars/alisa_fight_char.tres")
var lina_fight = preload("res://scenes/globals/fight_chars/lina_fight_char.tres")

var enemy_fight

signal turn_ended()
signal alisa_input_pressed(direction)
signal lina_input_pressed(direction)
signal battle_over()

func _process(delta):
	
	if fight_active:
		testing_stats_show()
		clamping()
		control_handle()
		ko_handle()


func testing_stats_show():
	$SubViewportContainer/SubViewport/Alisa/HP.text = "alisa hp " + str(alisa_fight.hp)
	$SubViewportContainer/SubViewport/Alisa/ATK.text = "alisa atk " + str(alisa_fight.atk)
	
	$SubViewportContainer/SubViewport/Lina/HP.text = "lina hp " + str(lina_fight.hp)
	$SubViewportContainer/SubViewport/Lina/ATK.text = "lina atk " + str(lina_fight.atk)
	
	$SubViewportContainer/SubViewport/Enemy/HP.text = "enemy hp " + str(enemy_fight.hp)
	$SubViewportContainer/SubViewport/Enemy/ATK.text = "enemy atk " + str(enemy_fight.atk)


func start(enemy):
	get_tree().paused = true
	visible = true
	enemy_fight = enemy.duplicate()
	characters_ready()
	create_queue()
	turn()
	fight_active = true

func finish():
	visible = false
	turn()
	fight_active = false
	get_tree().paused = false
	battle_over.emit()

func characters_ready():
	alisa_fight.hp = Globals.alisa_hp
	alisa_fight.atk = Globals.alisa_atk
	alisa_fight.def = Globals.alisa_def
	alisa_fight.spd = 100 - Globals.alisa_spd + 100
	alisa_fight.item = Globals.alisa_equipped_item
	alisa_fight.skills = Globals.alisa_equipped_skills
	
	lina_fight.hp = Globals.lina_hp
	lina_fight.atk = Globals.lina_atk
	lina_fight.def = Globals.lina_def
	lina_fight.spd = 100 - Globals.lina_spd + 100
	lina_fight.item = Globals.lina_equipped_item
	lina_fight.skills = Globals.lina_equipped_skills
	
	enemy_fight.spd = 100 - enemy_fight.spd + 100
	enemy_base_hp = enemy_fight.hp
	
	valid_targets.append(alisa_fight)
	valid_targets.append(lina_fight)


func create_queue():
	queue.clear()
	alisa_base_spd = alisa_fight.spd
	lina_base_spd = lina_fight.spd
	enemy_base_spd = enemy_fight.spd
	for i in 10:
		for j in 1000:
			if alisa_fight.spd != 0:
				alisa_fight.spd -= 1
			if lina_fight.spd != 0:
				lina_fight.spd -= 1
			if enemy_fight.spd != 0:
				enemy_fight.spd -= 1
			if alisa_fight.spd == 0:
				queue.append(alisa_fight)
				alisa_fight.spd = alisa_base_spd
				break
			if lina_fight.spd == 0:
				queue.append(lina_fight)
				lina_fight.spd = lina_base_spd
				break
			if enemy_fight.spd == 0:
				queue.append(enemy_fight)
				enemy_fight.spd = enemy_base_spd
				break
	current_turn = queue[0]

func new_turn_queue():
	queue.pop_front()
	for j in 1000:
		if alisa_fight.spd != 0:
			alisa_fight.spd -= 1
		if lina_fight.spd != 0:
			lina_fight.spd -= 1
		if enemy_fight.spd != 0:
			enemy_fight.spd -= 1
		if alisa_fight.spd == 0:
			queue.append(alisa_fight)
			alisa_fight.spd = alisa_base_spd
			break
		if lina_fight.spd == 0:
			queue.append(lina_fight)
			lina_fight.spd = lina_base_spd
			break
		if enemy_fight.spd == 0:
			queue.append(enemy_fight)
			enemy_fight.spd = enemy_base_spd
			break
	current_turn = queue[0]

func turn():
	match current_turn:
		enemy_fight: 
			turn_enemy()
			$SubViewportContainer/SubViewport/CurrentTurn.text = "current_turn enemy"
		alisa_fight: 
			turn_player(alisa_fight)
			$SubViewportContainer/SubViewport/CurrentTurn.text = "current_turn alisa"
		lina_fight: 
			turn_player(lina_fight)
			$SubViewportContainer/SubViewport/CurrentTurn.text = "current_turn lina"
	new_turn_queue()
	
func turn_enemy():
	var random_skill_id = rng.randi_range(0, enemy_fight.skills.items.size()-1)
	var random_skill_target = rng.randi_range(0, valid_targets.size()-1)
	var target
	match enemy_fight.skills.items[random_skill_id].effect:
		"damage": target = valid_targets[random_skill_target]
		"heal": target = enemy_fight
		"buff": target = enemy_fight
	var callable = Callable(self, enemy_fight.skills.items[random_skill_id].effect)
	callable.call(enemy_fight.skills.items[random_skill_id].effect_info, enemy_fight.skills.items[random_skill_id].value, target, enemy_fight)
	
func turn_player(player):
	if player == alisa_fight:
		alisa_skill_pool = skill_shuffle_and_display(player, alisa_skill_display_up, alisa_skill_display_down, alisa_skill_display_right, alisa_skill_display_left, alisa_skill_pool)
	if player == lina_fight:
		lina_skill_pool = skill_shuffle_and_display(player, lina_skill_display_up, lina_skill_display_down, lina_skill_display_right, lina_skill_display_left, lina_skill_pool)
	if player == alisa_fight:
		await alisa_input_pressed
		skill_handle(alisa_fight, alisa_skill_pool, alisa_current_direction)
	if player == lina_fight:
		await lina_input_pressed
		skill_handle(lina_fight, lina_skill_pool, lina_current_direction)
	
func skill_shuffle_and_display(player, up, down, left, right, skill_pool):
	if player.skills.items.size() < 5: 
		skill_pool = player.skills.items
		fill_skill_select(up, down, right, left, skill_pool)
	if player.skills.items.size() >= 5: 
		for i in 4:
			player.skills.items.shuffle()
			skill_pool[i] = player.skills.items[i]
			fill_skill_select(up, down, right, left, skill_pool)
	return skill_pool

func fill_skill_select(up, down, left, right, skills):
	if skills.size() > 0:
		up.text = skills[0].title
	if skills.size() > 1:
		down.text = skills[1].title
	if skills.size() > 2:
		right.text = skills[2].title
	if skills.size() > 3:
		left.text = skills[3].title



func control_handle():
	if Input.is_action_just_pressed("left_fight_up") and alisa_skill_pool.size() > 0:
		alisa_input_pressed.emit(directions.UP)
	if Input.is_action_just_pressed("left_fight_down") and alisa_skill_pool.size() > 1:
		alisa_input_pressed.emit(directions.DOWN)
	if Input.is_action_just_pressed("left_fight_right") and alisa_skill_pool.size() > 2:
		alisa_input_pressed.emit(directions.RIGHT)
	if Input.is_action_just_pressed("left_fight_left") and alisa_skill_pool.size() > 3:
		alisa_input_pressed.emit(directions.LEFT)
	
	if Input.is_action_just_pressed("right_fight_up") and lina_skill_pool.size() > 0:
		lina_input_pressed.emit(directions.UP)
		
	if Input.is_action_just_pressed("right_fight_down") and lina_skill_pool.size() > 1:
		lina_input_pressed.emit(directions.DOWN)
	if Input.is_action_just_pressed("right_fight_right") and lina_skill_pool.size() > 2:
		lina_input_pressed.emit(directions.RIGHT)
	if Input.is_action_just_pressed("right_fight_left") and lina_skill_pool.size() > 3:
		lina_input_pressed.emit(directions.LEFT)

func skill_handle(user, skill_pool, direction):
	if skill_pool[direction].effect == "damage":
		target = enemy_fight
	if skill_pool[direction].effect == "heal":
		target = user
	if skill_pool[direction].effect == "buff":
		target = user
	
	callable = Callable(self, skill_pool[direction].effect)
	callable.call(skill_pool[direction].effect_info, skill_pool[direction].value, target, user)

func ko_handle():
	if alisa_fight.hp == 0:
		valid_targets.erase(alisa_fight)
	if lina_fight.hp == 0:
		valid_targets.erase(lina_fight)
	if enemy_fight.hp == 0:
		finish()
	if valid_targets.is_empty():
		finish()



func clamping():
	alisa_fight.hp = clamp(alisa_fight.hp, 0, Globals.alisa_hp)
	lina_fight.hp = clamp(lina_fight.hp, 0, Globals.alisa_hp)
	enemy_fight.hp = clamp(enemy_fight.hp, 0, enemy_base_hp)



func damage(effect_info, value, target, user):
	target.hp -= int(value * user.atk)
	await get_tree().create_timer(0.5).timeout
	turn_ended.emit()

func heal(effect_info, value, target, user):
	target.hp += 20
	await get_tree().create_timer(0.5).timeout
	turn_ended.emit()

func buff(effect_info, value, target, user):
	if effect_info == "atk":
		target.atk *= 1.1
	await get_tree().create_timer(0.5).timeout
	turn_ended.emit()



func _on_turn_ended() -> void:
	if fight_active:
		turn()


func _on_alisa_input_pressed(direction: Variant) -> void:
	match direction:
			directions.UP: alisa_current_direction = 0
			directions.DOWN: alisa_current_direction = 1
			directions.RIGHT: alisa_current_direction = 2
			directions.LEFT: alisa_current_direction = 3

func _on_lina_input_pressed(direction: Variant) -> void:
	match direction:
			directions.UP: lina_current_direction = 0
			directions.DOWN: lina_current_direction = 1
			directions.RIGHT: lina_current_direction = 2
			directions.LEFT: lina_current_direction = 3
