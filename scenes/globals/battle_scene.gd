extends CanvasLayer

@export var fight_active = false

var current_turn

var alisa_skill_pool: Array[Skills]
var lina_skill_pool: Array[Skills]

var callable
var targets: Array
var battle_lost = false

var queue: Array
var max_speed
var speed_frame
var alisa_queue_turn_memory: Array
var lina_queue_turn_memory: Array
var enemy_queue_turn_memory: Array
var valid_targets: Array

var slow_points = 0.0
var fast_points = 0.0

var rng = RandomNumberGenerator.new()

enum directions
{
	UP, DOWN, LEFT, RIGHT
}
var alisa_current_direction
var lina_current_direction

@onready var alisa_skill_display_up = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls/UpName
@onready var alisa_skill_display_down = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls/DownName
@onready var alisa_skill_display_left = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls/LeftName
@onready var alisa_skill_display_right = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls/RightName
@onready var alisa_skill_display_up_icon = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls/IconUp
@onready var alisa_skill_display_down_icon = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls/IconDown
@onready var alisa_skill_display_left_icon = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls/IconLeft
@onready var alisa_skill_display_right_icon = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls/IconRight
@onready var alisa_skill_display_up_particle = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls/ParticleUp
@onready var alisa_skill_display_down_particle = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls/ParticleDown
@onready var alisa_skill_display_left_particle = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls/ParticleLeft
@onready var alisa_skill_display_right_particle = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls/ParticleRight
@onready var alisa_hp_bar = $SubViewportContainer/SubViewport/AllThe2d/AlisaHP
@onready var alisa_skill_controls = $SubViewportContainer/SubViewport/AllThe2d/LeftContorls

@onready var lina_skill_display_up = $SubViewportContainer/SubViewport/AllThe2d/RightContorls/UpName
@onready var lina_skill_display_down = $SubViewportContainer/SubViewport/AllThe2d/RightContorls/DownName
@onready var lina_skill_display_left = $SubViewportContainer/SubViewport/AllThe2d/RightContorls/LeftName
@onready var lina_skill_display_right = $SubViewportContainer/SubViewport/AllThe2d/RightContorls/RightName
@onready var lina_skill_display_up_icon = $SubViewportContainer/SubViewport/AllThe2d/RightContorls/IconUp
@onready var lina_skill_display_down_icon = $SubViewportContainer/SubViewport/AllThe2d/RightContorls/IconDown
@onready var lina_skill_display_left_icon = $SubViewportContainer/SubViewport/AllThe2d/RightContorls/IconLeft
@onready var lina_skill_display_right_icon = $SubViewportContainer/SubViewport/AllThe2d/RightContorls/IconRight
@onready var lina_skill_display_up_particle = $SubViewportContainer/SubViewport/AllThe2d/RightContorls/ParticleUp
@onready var lina_skill_display_down_particle = $SubViewportContainer/SubViewport/AllThe2d/RightContorls/ParticleDown
@onready var lina_skill_display_left_particle = $SubViewportContainer/SubViewport/AllThe2d/RightContorls/ParticleLeft
@onready var lina_skill_display_right_particle = $SubViewportContainer/SubViewport/AllThe2d/RightContorls/ParticleRight
@onready var lina_hp_bar = $SubViewportContainer/SubViewport/AllThe2d/LinaHP
@onready var lina_skill_controls = $SubViewportContainer/SubViewport/AllThe2d/RightContorls

@onready var alisa_sprite = $SubViewportContainer/SubViewport/AllThe3d/AlisaSprite
@onready var lina_sprite = $SubViewportContainer/SubViewport/AllThe3d/LinaSprite

@onready var enemy_sprite = $SubViewportContainer/SubViewport/AllThe3d/EnemySprite
@onready var enemy_hp_bar = $SubViewportContainer/SubViewport/AllThe2d/ColorRect3/EnemyHP
@onready var enemy_hp_bar_container = $SubViewportContainer/SubViewport/AllThe2d/ColorRect3
@onready var enemy_skill_name = $SubViewportContainer/SubViewport/AllThe2d/EnemySkill/Name
@onready var enemy_skill_icon = $SubViewportContainer/SubViewport/AllThe2d/EnemySkill/Icon
@onready var enemy_anim = $SubViewportContainer/SubViewport/AllThe2d/EnemyAnimation

@onready var camera_bob_anim = $SubViewportContainer/SubViewport/AllThe3d/CameraBobAnimation
@onready var interface_anim = $SubViewportContainer/SubViewport/AllThe2d/InterfaceAnimation

@onready var battle_icons = [$SubViewportContainer/SubViewport/AllThe2d/QueueIcons/Icon1,$SubViewportContainer/SubViewport/AllThe2d/QueueIcons/Icon2,$SubViewportContainer/SubViewport/AllThe2d/QueueIcons/Icon3,$SubViewportContainer/SubViewport/AllThe2d/QueueIcons/Icon4,$SubViewportContainer/SubViewport/AllThe2d/QueueIcons/Icon5,$SubViewportContainer/SubViewport/AllThe2d/QueueIcons/Icon6,$SubViewportContainer/SubViewport/AllThe2d/QueueIcons/Icon7,$SubViewportContainer/SubViewport/AllThe2d/QueueIcons/Icon8,$SubViewportContainer/SubViewport/AllThe2d/QueueIcons/Icon9,$SubViewportContainer/SubViewport/AllThe2d/QueueIcons/Icon10,$SubViewportContainer/SubViewport/AllThe2d/QueueIcons/Icon11]
@onready var icon_reset = $SubViewportContainer/SubViewport/AllThe2d/IconsReset
var draw_icon_index = 9

@onready var alisa_buff_icons = [$SubViewportContainer/SubViewport/AllThe2d/LeftContorls/AlisaBuffIcons/IconBase1,$SubViewportContainer/SubViewport/AllThe2d/LeftContorls/AlisaBuffIcons/IconBase2,$SubViewportContainer/SubViewport/AllThe2d/LeftContorls/AlisaBuffIcons/IconBase3,$SubViewportContainer/SubViewport/AllThe2d/LeftContorls/AlisaBuffIcons/IconBase4,$SubViewportContainer/SubViewport/AllThe2d/LeftContorls/AlisaBuffIcons/IconBase5,$SubViewportContainer/SubViewport/AllThe2d/LeftContorls/AlisaBuffIcons/IconBase6]
@onready var lina_buff_icons = [$SubViewportContainer/SubViewport/AllThe2d/RightContorls/LinaBuffIcons/IconBase6,$SubViewportContainer/SubViewport/AllThe2d/RightContorls/LinaBuffIcons/IconBase5,$SubViewportContainer/SubViewport/AllThe2d/RightContorls/LinaBuffIcons/IconBase4,$SubViewportContainer/SubViewport/AllThe2d/RightContorls/LinaBuffIcons/IconBase3,$SubViewportContainer/SubViewport/AllThe2d/RightContorls/LinaBuffIcons/IconBase2,$SubViewportContainer/SubViewport/AllThe2d/RightContorls/LinaBuffIcons/IconBase1]
var alisa_buff_icon_index = 0
var lina_buff_icon_index = 0
var enemy_buff_icon_index = 0

@onready var attack_sound = $Audio/AttackSound
@onready var buff_sound = $Audio/Buff
@onready var heal_sound = $Audio/Heal
@onready var spell_not_sound = $Audio/SpellIsNot

var alisa_fight = preload("res://scenes/globals/fight_chars/alisa_fight_char.tres")
var lina_fight = preload("res://scenes/globals/fight_chars/lina_fight_char.tres")

var enemy_fight

signal turn_ended()
signal alisa_input_pressed(direction)
signal lina_input_pressed(direction)
signal battle_over()
signal confrim_pressed


func _process(delta):
	$Guide/Screen1/Label.text = tr("SCREEN1")
	$Guide/Screen2/Label.text = tr("SCREEN2")
	$Guide/Screen3/Label.text = tr("SCREEN3")
	$Guide/Screen4/Label.text = tr("SCREEN4")
	$Guide/Screen5/Label.text = tr("SCREEN5")
	if fight_active:
		confirm()
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


func start(enemy, enemy_animation):
	alisa_skill_display_up_particle.emitting = false
	alisa_skill_display_down_particle.emitting = false
	alisa_skill_display_left_particle.emitting = false
	alisa_skill_display_right_particle.emitting = false
	lina_skill_display_up_particle.emitting = false
	lina_skill_display_down_particle.emitting = false
	lina_skill_display_left_particle.emitting = false
	lina_skill_display_right_particle.emitting = false
	battle_lost = false
	$Audio/Encounter.play()
	enemy_sprite.idle()
	await get_tree().create_timer(0.8).timeout
	slow_points = 0.0
	fast_points = 0.0
	get_tree().paused = true
	visible = true
	enemy_fight = enemy.duplicate()
	interface_anim.play('remove_both')
	camera_bob_anim.play("camera_bob")
	await get_tree().create_timer(0.3).timeout
	characters_ready(enemy_animation)
	await get_tree().create_timer(0.3).timeout
	$Audio/FightOST.play()
	await get_tree().create_timer(0.4).timeout
	
	turn()
	fight_active = true
	
	
	

func finish():
	Transition.play_battle_end_transiton(enemy_fight.reward_points)
	fight_active = false
	get_tree().paused = false
	await get_tree().create_timer(2.3).timeout
	battle_over.emit()
	$Audio/FightOST.stop()
	visible = false
	reset_buff_icons()

func characters_ready(enemy_animation):
	
	alisa_fight.natural_spd = Globals.alisa_spd
	lina_fight.natural_spd = Globals.lina_spd
	enemy_fight.natural_spd = enemy_fight.spd
	speed_frame_calculate_on_start()
	alisa_fight.hp = Globals.alisa_hp
	alisa_fight.atk = Globals.alisa_atk
	alisa_fight.def = Globals.alisa_def
	alisa_fight.spd = (speed_frame/2) - Globals.alisa_spd + (speed_frame/2)
	alisa_fight.item = Globals.alisa_equipped_item
	alisa_fight.skills.clear()
	for i in Globals.alisa_skill_inventory.size():
		for j in Globals.alisa_equipped_skills.size():
			if i == Globals.alisa_equipped_skills[j]:
				alisa_fight.skills.append(Globals.alisa_skill_inventory[i])
	alisa_fight.base_hp = alisa_fight.hp
	alisa_fight.base_spd = alisa_fight.spd
	alisa_sprite.init(alisa_fight)
	alisa_hp_bar.max_value = alisa_fight.base_hp
	alisa_hp_bar.value = alisa_fight.base_hp
	alisa_hp_bar.get_children()[0].text = str(alisa_fight.hp) + "/" + str(alisa_fight.base_hp)
	
	lina_fight.hp = Globals.lina_hp
	lina_fight.atk = Globals.lina_atk
	lina_fight.def = Globals.lina_def
	lina_fight.spd = (speed_frame/2) - Globals.lina_spd + (speed_frame/2)
	lina_fight.item = Globals.lina_equipped_item
	lina_fight.skills.clear()
	for i in Globals.lina_skill_inventory.size():
		for j in Globals.lina_equipped_skills.size():
			if i == Globals.lina_equipped_skills[j]:
				lina_fight.skills.append(Globals.lina_skill_inventory[i])
	lina_fight.base_hp = lina_fight.hp
	lina_fight.base_spd = lina_fight.spd
	lina_hp_bar.max_value = lina_fight.base_hp
	lina_hp_bar.value = lina_fight.base_hp
	lina_sprite.init(lina_fight)
	lina_hp_bar.get_children()[0].text = str(lina_fight.hp) + "/" + str(lina_fight.base_hp)
	
	
	enemy_fight.spd = (speed_frame/2) - enemy_fight.spd + (speed_frame/2)
	enemy_fight.base_hp = enemy_fight.hp
	enemy_fight.base_spd = enemy_fight.spd
	enemy_hp_bar.max_value = enemy_fight.base_hp
	enemy_hp_bar.value = enemy_fight.base_hp
	enemy_sprite.init(enemy_animation)
	
	valid_targets.clear()
	if Globals.is_alisa_in_party:
		valid_targets.append(alisa_fight)
	valid_targets.append(lina_fight)
	
	enemy_sprite.idle()
	alisa_sprite.idle_no_turn()
	lina_sprite.idle_no_turn()
	create_queue()
	if not Globals.is_alisa_in_party:
		alisa_sprite.visible = false
		alisa_hp_bar.visible = false
	if Globals.is_alisa_in_party:
		alisa_sprite.visible = true
		alisa_hp_bar.visible = true



func create_queue():
	queue.clear()
	alisa_queue_turn_memory.clear()
	lina_queue_turn_memory.clear()
	enemy_queue_turn_memory.clear()
	queue.append(null)
	alisa_queue_turn_memory.append(null)
	lina_queue_turn_memory.append(null)
	enemy_queue_turn_memory.append(null)
	for i in 10:
		for j in 1000:
			if alisa_fight.spd != 0:
				alisa_fight.spd -= 1
			if lina_fight.spd != 0:
				lina_fight.spd -= 1
			if enemy_fight.spd != 0:
				enemy_fight.spd -= 1
			if alisa_fight.spd == 0 and valid_targets.has(alisa_fight):
				queue.append(alisa_fight)
				alisa_fight.spd = alisa_fight.base_spd
				break
			if lina_fight.spd == 0 and valid_targets.has(lina_fight):
				queue.append(lina_fight)
				lina_fight.spd = lina_fight.base_spd
				break
			if enemy_fight.spd == 0:
				queue.append(enemy_fight)
				enemy_fight.spd = enemy_fight.base_spd
				break
		
		alisa_queue_turn_memory.append(alisa_fight.spd)
		lina_queue_turn_memory.append(lina_fight.spd)
		enemy_queue_turn_memory.append(enemy_fight.spd)
	draw_icons_full()

func new_turn_queue():
	var icons_remember = queue[0]
	queue.pop_front()
	alisa_queue_turn_memory.pop_front()
	lina_queue_turn_memory.pop_front()
	enemy_queue_turn_memory.pop_front()
	for j in 1000:
		if alisa_fight.spd != 0:
			alisa_fight.spd -= 1
		if lina_fight.spd != 0:
			lina_fight.spd -= 1
		if enemy_fight.spd != 0:
			enemy_fight.spd -= 1
		if alisa_fight.spd == 0 and valid_targets.has(alisa_fight):
			queue.append(alisa_fight)
			alisa_fight.spd = alisa_fight.base_spd
			break
		if lina_fight.spd == 0 and valid_targets.has(lina_fight):
			queue.append(lina_fight)
			lina_fight.spd = lina_fight.base_spd
			break
		if enemy_fight.spd == 0:
			queue.append(enemy_fight)
			enemy_fight.spd = enemy_fight.base_spd
			break
	alisa_queue_turn_memory.append(alisa_fight.spd)
	lina_queue_turn_memory.append(lina_fight.spd)
	enemy_queue_turn_memory.append(enemy_fight.spd)
	current_turn = queue[0]
	if icons_remember != null:
		draw_icons_last()

func ko_queue_refresh(kod_char):
	var id
	for i in 10:
		id = queue.find(kod_char)
		if id != -1:
			queue.remove_at(id)
			new_turn_queue()
		else:
			break

func buff_queue_refresh(targets):
	alisa_fight.spd = alisa_queue_turn_memory[0]
	lina_fight.spd = lina_queue_turn_memory[0]
	enemy_fight.spd = enemy_queue_turn_memory[0]
	speed_frame_calculate_on_buff()
	create_queue()
	if targets[0] == enemy_fight:
		await enemy_sprite.anim_ended
	elif targets[0] == alisa_fight:
		await alisa_sprite.anim_ended
	elif targets[0] == lina_fight:
		await lina_sprite.anim_ended
	targets.clear()
	turn_ended.emit()



func speed_frame_calculate_on_start():
	max_speed = alisa_fight.natural_spd
	if lina_fight.natural_spd > alisa_fight.natural_spd:
		max_speed = lina_fight.natural_spd
	if enemy_fight.natural_spd > lina_fight.natural_spd:
		max_speed = enemy_fight.natural_spd
	speed_frame = ceil(max_speed * 1.5)

func speed_frame_calculate_on_buff():
	max_speed = alisa_fight.natural_spd
	if lina_fight.natural_spd > alisa_fight.natural_spd:
		max_speed = lina_fight.natural_spd
	if enemy_fight.natural_spd > lina_fight.natural_spd:
		max_speed = enemy_fight.natural_spd
	speed_frame = ceil(max_speed * 1.5)
	alisa_fight.base_spd = (speed_frame/2) - alisa_fight.natural_spd + (speed_frame/2)
	lina_fight.base_spd = (speed_frame/2) - lina_fight.natural_spd + (speed_frame/2)
	enemy_fight.base_spd = (speed_frame/2) - enemy_fight.natural_spd + (speed_frame/2)



func draw_icons_full():
	reset_icons()
	await get_tree().create_timer(0.5).timeout
	draw_icon_index = 9
	if queue[0] == null:
		for i in queue.size():
			if queue[i] != null:
				battle_icons[i-1].texture = queue[i].icon
	else:
		for i in queue.size():
			battle_icons[i].texture = queue[i].icon
	
	
func draw_icons_last():
	draw_icon_index += 1
	if draw_icon_index > 10:
		draw_icon_index = 0
	battle_icons[draw_icon_index].texture = queue[9].icon
	new_turn_icons()
	

func new_turn_icons():
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	for i in battle_icons.size():
		if i != draw_icon_index:
			tween.tween_property(battle_icons[i], "position", Vector2(battle_icons[i].position.x, battle_icons[i].position.y - 19), 0.5).set_trans(Tween.TRANS_ELASTIC)
		else:
			tween.tween_property(battle_icons[i], "position", Vector2(battle_icons[i].position.x + 27, battle_icons[i].position.y), 0.5).set_trans(Tween.TRANS_ELASTIC)
	await tween.finished
	if draw_icon_index != 10:
		battle_icons[draw_icon_index+1].position = Vector2(-16, 182.0)
	else:
		battle_icons[0].position = Vector2(-16, 182.0)

func reset_icons():
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	for i in battle_icons.size():
		tween.tween_property(battle_icons[i], "position", Vector2(battle_icons[i].position.x - 27, battle_icons[i].position.y), 0.5).set_trans(Tween.TRANS_QUART)
	await tween.finished
	icon_reset.play("RESETT")
	var tween1 = get_tree().create_tween()
	tween1.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween1.set_parallel(true)
	for i in battle_icons.size():
		if i != 10:
			tween1.tween_property(battle_icons[i], "position", Vector2(battle_icons[i].position.x + 27, battle_icons[i].position.y), 0.5).set_trans(Tween.TRANS_QUART)
	await tween1.finished
	


func draw_buff_icon(icon_set, icon, index):
	icon_set[index].emitting = true
	icon_set[index].get_children()[0].texture = icon
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	print(icon_set[index].get_child(0))
	tween.tween_property(icon_set[index].get_child(0), "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)

func reset_buff_icons():
	$SubViewportContainer/SubViewport/AllThe2d/BuffIcons/BuffIconReset.play("RESET")
	alisa_buff_icon_index = 0
	lina_buff_icon_index = 0
	enemy_buff_icon_index = 0


func turn():
	new_turn_queue()
	
	alisa_skill_display_up_particle.gravity.y = 0
	alisa_skill_display_down_particle.gravity.y = 0
	alisa_skill_display_left_particle.gravity.x = 0
	alisa_skill_display_right_particle.gravity.x = 0
	lina_skill_display_up_particle.gravity.y = 0
	lina_skill_display_down_particle.gravity.y = 0
	lina_skill_display_left_particle.gravity.x = 0
	lina_skill_display_right_particle.gravity.x = 0
	
	match current_turn:
		enemy_fight: 
			turn_enemy()
		alisa_fight: 
			turn_player(alisa_fight)
		lina_fight: 
			turn_player(lina_fight)
	
func turn_enemy():
	await get_tree().create_timer(1).timeout
	if valid_targets.is_empty():
		turn()
		return
	var callable: Callable
	
	var min_hp_target = valid_targets[0]
	var max_hp_target = valid_targets[0]
	for i in valid_targets:
		if i.hp < min_hp_target.hp:
			min_hp_target = i
		if i.hp > max_hp_target.hp:
			max_hp_target = i
	
	var max_damage = 0
	print("search started")
	for i in enemy_fight.skills:
		print("new cycle")
		if i.effect == "damage":
			print("damage_found" + i.effect_info + str(min_hp_target))
			if i.effect_info == "hp":
				print("hp damage")
				max_damage = int((i.value / 10) * (enemy_fight.atk/2 + enemy_fight.atk/2 - min_hp_target.def/2))
			elif i.effect_info == "speed":
				max_damage = int((i.value / 10) * (enemy_fight.atk/2 + enemy_fight.atk/2 - min_hp_target.def/2))
			elif i.effect_info == "vampirism":
				max_damage = int((i.value / 10) * (enemy_fight.atk/2 + enemy_fight.atk/2 - min_hp_target.def/2))
			elif i.effect_info == "multi-hit":
				max_damage = int((i.value / 10) * (enemy_fight.atk/2 + enemy_fight.atk/2 - min_hp_target.def/2)) * 3
			if max_damage > min_hp_target.hp:
				enemy_skill_icon.texture = i.icon
				match Globals.language:
					"ENG":enemy_skill_name.text = i.title
					"RUS":enemy_skill_name.text = i.rus_title
				enemy_anim.play("show_skill")
				callable = Callable(self, i.effect)
				callable.call(null, i.effect_info, i.value, min_hp_target, enemy_fight)
				print("max damage applied " + str(max_damage))
				return
	print("max damage not applied" + str(max_damage))
	var temp_skills: Array
	for i in enemy_fight.skills:
		print("hp", enemy_fight.hp, "base_hp", enemy_fight.base_hp)
		if i.effect == "heal" and enemy_fight.hp < enemy_fight.base_hp / 2:
			temp_skills.append(i)
		elif i.effect == "buff" and enemy_buff_icon_index !=6:
			temp_skills.append(i)
		elif i.effect != "heal" and i.effect != "buff":
			temp_skills.append(i)
	
	var random_skill_id = randi_range(0, temp_skills.size()-1)
	targets.clear()
	match temp_skills[random_skill_id].effect:
		"damage": targets.append(max_hp_target)
		"heal": targets.append(enemy_fight)
		"buff": targets.append(enemy_fight)
	enemy_skill_icon.texture = temp_skills[random_skill_id].icon
	match Globals.language:
		"ENG":enemy_skill_name.text = temp_skills[random_skill_id].title
		"RUS":enemy_skill_name.text = temp_skills[random_skill_id].rus_title
	enemy_anim.play("show_skill")
	callable = Callable(self, temp_skills[random_skill_id].effect)
	callable.call(null, temp_skills[random_skill_id].effect_info, temp_skills[random_skill_id].value, temp_skills[random_skill_id].upgrade, temp_skills[random_skill_id].steps, targets, enemy_fight)
	
func turn_player(player):
	
	if player == alisa_fight:
		alisa_skill_pool = skill_shuffle_and_display(player, alisa_skill_display_up, 
		alisa_skill_display_down, alisa_skill_display_right, alisa_skill_display_left, 
		alisa_skill_display_up_icon, alisa_skill_display_down_icon, alisa_skill_display_right_icon, 
		alisa_skill_display_left_icon, alisa_skill_pool, alisa_skill_controls, alisa_buff_icon_index,
		alisa_skill_display_up_particle, alisa_skill_display_down_particle, alisa_skill_display_right_particle, alisa_skill_display_left_particle)
		
		
		
	if player == lina_fight:
		lina_skill_pool = skill_shuffle_and_display(player, lina_skill_display_up, 
		lina_skill_display_down, lina_skill_display_right, lina_skill_display_left, 
		lina_skill_display_up_icon, lina_skill_display_down_icon, lina_skill_display_right_icon, 
		lina_skill_display_left_icon, lina_skill_pool, lina_skill_controls, lina_buff_icon_index,
		lina_skill_display_up_particle, lina_skill_display_down_particle, lina_skill_display_right_particle, lina_skill_display_left_particle)
		
		
	if InteractionMemory.first_fight:
		InteractionMemory.first_fight = false
		var tween1 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween1.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween1.tween_property($Guide/Screen1, "modulate", Color(1.0, 1.0, 1.0), 1)
		await get_tree().create_timer(1).timeout
		var tween2 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween2.tween_property($Guide/Screen1/Confirm, "modulate", Color(1.0, 1.0, 1.0), 1)
		await confrim_pressed
		var tween3 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween3.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween3.tween_property($Guide/Screen1, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
		tween3.tween_property($Guide/Screen2, "modulate", Color(1.0, 1.0, 1.0), 1)
		await get_tree().create_timer(1).timeout
		var tween35 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween35.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween35.tween_property($Guide/Screen2/Confirm, "modulate", Color(1.0, 1.0, 1.0), 1)
		await confrim_pressed
		var tween4 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween4.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween4.tween_property($Guide/Screen2, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
		tween4.tween_property($Guide/Screen3, "modulate", Color(1.0, 1.0, 1.0), 1)
		await get_tree().create_timer(1).timeout
		var tween45 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween45.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween45.tween_property($Guide/Screen3/Confirm, "modulate", Color(1.0, 1.0, 1.0), 1)
		await confrim_pressed
		var tween5 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween5.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween5.tween_property($Guide/Screen3, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
		tween5.tween_property($Guide/Screen4, "modulate", Color(1.0, 1.0, 1.0), 1)
		await get_tree().create_timer(1).timeout
		var tween55 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween55.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween55.tween_property($Guide/Screen4/Confirm, "modulate", Color(1.0, 1.0, 1.0), 1)
		await confrim_pressed
		var tween6 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween6.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween6.tween_property($Guide/Screen4, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
		tween6.tween_property($Guide/Screen5, "modulate", Color(1.0, 1.0, 1.0), 1)
		await get_tree().create_timer(1).timeout
		var tween65 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween65.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween65.tween_property($Guide/Screen5/Confirm, "modulate", Color(1.0, 1.0, 1.0), 1)
		await confrim_pressed
		var tween7 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween7.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween7.tween_property($Guide/Screen5, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
		
		
	
	if player == alisa_fight:
		await get_tree().create_timer(0.5).timeout
		for i in alisa_skill_pool.size():
			if alisa_skill_pool[i].effect == "buff" and alisa_buff_icon_index == 6:
				if i == alisa_skill_pool.size()-1:
					interface_anim.play('remove_left')
					alisa_skill_pool.clear()
					spell_not_sound.play()
					await get_tree().create_timer(0.5).timeout
					turn_ended.emit()
					return
			else:
				break
			
		alisa_sprite.idle_turn()
		for i in 1000:
			await alisa_input_pressed
			if alisa_current_direction == 0 and alisa_skill_pool[0].effect == "buff" and alisa_buff_icon_index == 6:
				spell_not_sound.play()
			elif alisa_current_direction == 1 and alisa_skill_pool[1].effect == "buff" and alisa_buff_icon_index == 6:
				spell_not_sound.play()
			elif alisa_current_direction == 2 and alisa_skill_pool[2].effect == "buff" and alisa_buff_icon_index == 6:
				spell_not_sound.play()
			elif alisa_current_direction == 3 and alisa_skill_pool[3].effect == "buff" and alisa_buff_icon_index == 6:
				spell_not_sound.play()
			else:
				break
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(alisa_skill_display_up, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(alisa_skill_display_down, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(alisa_skill_display_left, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(alisa_skill_display_right, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(alisa_skill_display_up_icon, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(alisa_skill_display_down_icon, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(alisa_skill_display_left_icon, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(alisa_skill_display_right_icon, "modulate", Color("#ffffff00"), 0.3)
		
		alisa_skill_display_up_particle.emitting = false
		alisa_skill_display_down_particle.emitting = false
		alisa_skill_display_left_particle.emitting = false
		alisa_skill_display_right_particle.emitting = false
		if alisa_current_direction == 0:
			alisa_skill_display_up_particle.gravity.y = -100
		elif alisa_current_direction == 1:
			alisa_skill_display_down_particle.gravity.y = 100
		elif alisa_current_direction == 2:
			alisa_skill_display_right_particle.gravity.x = 100
		elif alisa_current_direction == 3:
			alisa_skill_display_left_particle.gravity.x = -100
		skill_handle(alisa_fight, alisa_skill_pool, alisa_current_direction)
	
	if player == lina_fight:
		await get_tree().create_timer(0.5).timeout
		for i in lina_skill_pool.size():
			if lina_skill_pool[i].effect == "buff" and lina_buff_icon_index == 6:
				if i == lina_skill_pool.size()-1:
					interface_anim.play('remove_right')
					lina_skill_pool.clear()
					spell_not_sound.play()
					await get_tree().create_timer(0.5).timeout
					turn_ended.emit()
					return
			else:
				break
		lina_sprite.idle_turn()
		for i in 1000:
			await lina_input_pressed
			if lina_current_direction == 0 and lina_skill_pool[0].effect == "buff" and lina_buff_icon_index == 6:
				spell_not_sound.play()
			elif lina_current_direction == 1 and lina_skill_pool[1].effect == "buff" and lina_buff_icon_index == 6:
				spell_not_sound.play()
			elif lina_current_direction == 2 and lina_skill_pool[2].effect == "buff" and lina_buff_icon_index == 6:
				spell_not_sound.play()
			elif lina_current_direction == 3 and lina_skill_pool[3].effect == "buff" and lina_buff_icon_index == 6:
				spell_not_sound.play()
			else:
				break
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(lina_skill_display_up, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(lina_skill_display_down, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(lina_skill_display_left, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(lina_skill_display_right, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(lina_skill_display_up_icon, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(lina_skill_display_down_icon, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(lina_skill_display_left_icon, "modulate", Color("#ffffff00"), 0.3)
		tween.tween_property(lina_skill_display_right_icon, "modulate", Color("#ffffff00"), 0.3)
		
		lina_skill_display_up_particle.emitting = false
		lina_skill_display_down_particle.emitting = false
		lina_skill_display_left_particle.emitting = false
		lina_skill_display_right_particle.emitting = false
		if lina_current_direction == 0:
			lina_skill_display_up_particle.gravity.y = -100
		elif lina_current_direction == 1:
			lina_skill_display_down_particle.gravity.y = 100
		elif lina_current_direction == 2:
			lina_skill_display_right_particle.gravity.x = 100
		elif lina_current_direction == 3:
			lina_skill_display_left_particle.gravity.x = -100
			
		skill_handle(lina_fight, lina_skill_pool, lina_current_direction)
		
	
func skill_shuffle_and_display(player, up, down, left, right, icon_up, icon_down, icon_left, icon_right, skill_pool, side, buff_index, particle_up, particle_down, particle_left, particle_right):
	skills_clear()
	skill_pool.clear()
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if player.skills.size() < 5: 
		for i in player.skills.size():
			skill_pool.append(player.skills[i])
	if player.skills.size() >= 5: 
		player.skills.shuffle()
		for i in 4:
			skill_pool.append(player.skills[i])
	if skill_pool.size() > 0:
		match Globals.language:
			"ENG":up.text = player.skills[0].title
			"RUS":up.text = player.skills[0].rus_title
		icon_up.texture = player.skills[0].icon
		particle_up.emitting = true
		tween.tween_property(up, "modulate", Color("#ffffff"), 0.3)
		tween.tween_property(icon_up, "modulate", Color("#ffffff"), 0.3)
		if skill_pool[0].effect == "buff" and buff_index == 6:
			up.modulate = "777777"
		else:
			up.modulate = "ffffff"
			
	if skill_pool.size() > 1:
		match Globals.language:
			"ENG":down.text = player.skills[1].title
			"RUS":down.text = player.skills[1].rus_title
		icon_down.texture = player.skills[1].icon
		particle_down.emitting = true
		tween.tween_property(down, "modulate", Color("#ffffff"), 0.3)
		tween.tween_property(icon_down, "modulate", Color("#ffffff"), 0.3)
		if skill_pool[1].effect == "buff" and buff_index == 6:
			down.modulate = "777777"
		else:
			down.modulate = "ffffff"
			
	if skill_pool.size() > 2:
		match Globals.language:
			"ENG":left.text = player.skills[2].title
			"RUS":left.text = player.skills[2].rus_title
		icon_left.texture = player.skills[2].icon
		particle_left.emitting = true
		tween.tween_property(left, "modulate", Color("#ffffff"), 0.3)
		tween.tween_property(icon_left, "modulate", Color("#ffffff"), 0.3)
		if skill_pool[2].effect == "buff" and buff_index == 6:
			left.modulate = "777777"
		else:
			left.modulate = "ffffff"
			
	if skill_pool.size() > 3:
		match Globals.language:
			"ENG":right.text = player.skills[3].title
			"RUS":right.text = player.skills[3].rus_title
		icon_right.texture = player.skills[3].icon
		particle_right.emitting = true
		tween.tween_property(right, "modulate", Color("#ffffff"), 0.3)
		tween.tween_property(icon_right, "modulate", Color("#ffffff"), 0.3)
		if skill_pool[3].effect == "buff" and buff_index == 6:
			right.modulate = "777777"
		else:
			right.modulate = "ffffff"

	return skill_pool

func skills_clear():
	if current_turn == alisa_fight:
		alisa_skill_display_up.text = ""
		alisa_skill_display_down.text = ""
		alisa_skill_display_right.text = ""
		alisa_skill_display_left.text = ""
		alisa_skill_display_up_icon.set_texture(null)
		alisa_skill_display_down_icon.set_texture(null)
		alisa_skill_display_right_icon.set_texture(null)
		alisa_skill_display_left_icon.set_texture(null)
	
	if current_turn == lina_fight:
		lina_skill_display_up.text = ""
		lina_skill_display_down.text = ""
		lina_skill_display_right.text = ""
		lina_skill_display_left.text = ""
		lina_skill_display_up_icon.set_texture(null)
		lina_skill_display_down_icon.set_texture(null)
		lina_skill_display_right_icon.set_texture(null)
		lina_skill_display_left_icon.set_texture(null)



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
	targets.clear()
	if skill_pool[direction].effect == "damage":
		targets.append(enemy_fight)
	if skill_pool[direction].effect == "heal":
		targets.append(user)
	if skill_pool[direction].effect == "buff":
		if skill_pool[direction].target == "self":
			targets.append(user)
		if skill_pool[direction].target == "both":
			targets.append(alisa_fight)
			targets.append(lina_fight)
	
	callable = Callable(self, skill_pool[direction].effect)
	callable.call(skill_pool[direction].icon, skill_pool[direction].effect_info, skill_pool[direction].value, skill_pool[direction].upgrade, skill_pool[direction].steps , targets, user)

func ko_handle():
	if alisa_fight.hp == 0 and valid_targets.has(alisa_fight):
		valid_targets.erase(alisa_fight)
		alisa_sprite.recieve_ko()
		create_queue()
	if lina_fight.hp == 0 and valid_targets.has(lina_fight):
		valid_targets.erase(lina_fight)
		lina_sprite.recieve_ko()
		create_queue()
	if enemy_fight.hp == 0:
		battle_lost = false
		fight_active = false
		await enemy_sprite.anim_ended
		enemy_sprite.recieve_ko()
		await enemy_sprite.anim_ended
		finish()
	if valid_targets.is_empty():
		print(1)
		battle_lost = true
		fight_active = false
		reset_buff_icons()
		await get_tree().create_timer(1).timeout
		$Audio/FightOST.stop()
		visible = false
		get_tree().paused = false
		battle_over.emit()
		SaveAndLoad.save_load(true)

func sum_value(level, steps):
	var power = 0
	for i in level:
		power += steps[level]
	return power

func clamping():
	alisa_fight.hp = clamp(alisa_fight.hp, 0, alisa_fight.base_hp)
	lina_fight.hp = clamp(lina_fight.hp, 0, lina_fight.base_hp)
	enemy_fight.hp = clamp(enemy_fight.hp, 0, enemy_fight.base_hp)



func damage(icon, effect_info, value, level, steps, targets, user):
	value += sum_value(level, steps)
	attack_sound.pitch_scale = randf_range(0.9,1.1)
	if user == enemy_fight:
		enemy_sprite.punch()
	elif user == alisa_fight and effect_info == "hp":
		alisa_sprite.punch_slow()
	elif user == alisa_fight and effect_info == "speed":
		alisa_sprite.punch_fast()
	elif user == lina_fight and effect_info == "hp":
		lina_sprite.punch_slow()
	elif user == lina_fight and effect_info == "speed":
		lina_sprite.punch_fast()
	
	print("value", value, "atk",user.atk, "def", targets[0].def)
	if effect_info == "hp":
		if user == enemy_fight:
			targets[0].hp -= int(value * (user.atk/2 + (user.atk/2 - targets[0].def/2)))
		if user != enemy_fight:
			targets[0].hp -= int(value * (user.atk/2 + (user.atk/2 - targets[0].def/2)) + float(user.base_hp / 50 ))
			print("damage = ", int(value * (user.atk/2 + (user.atk/2 - targets[0].def/2)) + float(user.base_hp / 50 )))
			slow_points += 100.0 / user.natural_spd
	elif effect_info == "speed":
		targets[0].hp -= int(value * (user.atk/2 + (user.atk/2 - targets[0].def/2)) + user.natural_spd / 20)
		if user != enemy_fight:
			fast_points += 100.0 / user.natural_spd
	elif effect_info == "vampirism":
		if user == enemy_fight:
			targets[0].hp -= int(value * (user.atk/2 + (user.atk/2 + (user.atk/2 - targets[0].def/2))))
			user.hp += int((value) * (user.atk/2 +  + (user.atk/2 - targets[0].def/2))) / 20
		else:
			targets[0].hp -= int(value * (user.atk/2 + (user.atk/2 - targets[0].def/2)) + float(user.base_hp / 20 ))
			user.hp += int(value * (user.atk/2  + (user.atk/2 - targets[0].def/2)) + float(user.base_hp / 20 )) / 20
			slow_points += 100.0 / user.natural_spd
	elif effect_info == "multi-hit":
		targets[0].hp -= int((value / 10) * (user.atk/2 + (user.atk/2 + (user.atk/2 - targets[0].def/2))) + user.natural_spd / 20) * 3
		if user != enemy_fight:
			fast_points += 100.0 / user.natural_spd
		
	if targets[0] == enemy_fight:
		enemy_sprite.recieve_damage()
		enemy_recieve_damage(enemy_hp_bar, targets)
		await enemy_sprite.anim_ended
	elif targets[0] == alisa_fight:
		attack_sound.play()
		animate_progress_bar(alisa_hp_bar, targets)
		alisa_sprite.recieve_damage()
		await alisa_sprite.anim_ended
	elif targets[0] == lina_fight:
		attack_sound.play()
		animate_progress_bar(lina_hp_bar, targets)
		lina_sprite.recieve_damage()
		await lina_sprite.anim_ended
	
	turn_ended.emit()
	
func enemy_recieve_damage(bar,targets):
	await get_tree().create_timer(0.7).timeout
	attack_sound.play()
	animate_progress_bar(bar, targets)
	enemy_hp_bar_container.position.x += 10 
	await get_tree().create_timer(0.1).timeout
	enemy_hp_bar_container.position.x -= 20 
	await get_tree().create_timer(0.1).timeout
	enemy_hp_bar_container.position.x += 20 
	await get_tree().create_timer(0.1).timeout
	enemy_hp_bar_container.position.x -= 10 
	
func animate_progress_bar(bar, targets):
	clamping()
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for target in targets:
		tween.tween_property(bar, "max_value", float(target.base_hp), 0.5)
		tween.tween_property(bar, "value", float(target.hp), 0.5)
	if targets[0] != enemy_fight:
		bar.get_children()[0].text = str(targets[0].hp) + "/" + str(targets[0].base_hp)


func heal(icon, effect_info, value, level, steps, targets, user):
	value += sum_value(level, steps)
	heal_sound.pitch_scale = randf_range(0.9,1.1)
	for target in targets:
		target.hp += value 
	heal_sound.play()
	if user == enemy_fight:
		enemy_sprite.punch()
		animate_progress_bar(enemy_hp_bar, targets)
		await enemy_sprite.anim_ended
	elif user == alisa_fight:
		alisa_sprite.recieve_buff()
		animate_progress_bar(alisa_hp_bar, targets)
		await alisa_sprite.anim_ended
	elif user == lina_fight:
		lina_sprite.recieve_buff()
		animate_progress_bar(lina_hp_bar, targets)
		await lina_sprite.anim_ended
	turn_ended.emit()

func buff(icon, effect_info, value, level, steps, targets, user):
	value += sum_value(level, steps)
	buff_sound.pitch_scale = randf_range(0.9,1.1)
	buff_sound.play()
	if effect_info == "atk":
		for target in targets:
			target.atk *= value 
			print(target.atk, "+ ", value)
	if effect_info == "speed":
		for target in targets:
			target.natural_spd *= value 
			buff_queue_refresh(targets)
	if effect_info == "hp and def":
		var old_base_hp
		for target in targets:
			old_base_hp = target.base_hp
			target.base_hp *= value 
			target.hp += target.base_hp - old_base_hp
	if user == enemy_fight:
		enemy_buff_icon_index += 1
		enemy_sprite.punch()
		animate_progress_bar(enemy_hp_bar, targets)
		await enemy_sprite.anim_ended
	elif user == alisa_fight:
		alisa_sprite.recieve_buff()
		draw_buff_icon(alisa_buff_icons, icon, alisa_buff_icon_index)
		alisa_buff_icon_index += 1
		animate_progress_bar(alisa_hp_bar, targets)
		await alisa_sprite.anim_ended
	elif user == lina_fight:
		lina_sprite.recieve_buff()
		draw_buff_icon(lina_buff_icons, icon, lina_buff_icon_index)
		lina_buff_icon_index += 1
		animate_progress_bar(lina_hp_bar, targets)
		await lina_sprite.anim_ended
	if effect_info != "speed":
		turn_ended.emit()

func _on_turn_ended() -> void:

	enemy_sprite.idle()
	if valid_targets.has(alisa_fight):
		alisa_sprite.idle_no_turn()
	if valid_targets.has(lina_fight):
		lina_sprite.idle_no_turn()
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

func confirm():
	if Input.is_action_just_pressed("confirm"):
		confrim_pressed.emit()
