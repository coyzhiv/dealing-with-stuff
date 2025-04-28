extends Node3D

var windowed: bool = true

@onready var inventory = preload("res://scenes/globals/items/inventory.tres")

var alisa_equipped_item = preload("res://scenes/globals/items/badass_choker.tres")
var alisa_equipped_skills = preload("res://scenes/globals/skills/skill_equipped_alisa.tres")
var lina_equipped_item = preload("res://scenes/globals/items/hair_band.tres")
var lina_equipped_skills = preload("res://scenes/globals/skills/skill_equipped_lina.tres")

var alisa_base_hp = 100
var alisa_base_atk = 100
var alisa_base_def = 100
var alisa_base_spd = 100

var lina_base_hp = 100
var lina_base_atk = 100
var lina_base_def = 100
var lina_base_spd = 100

var alisa_hp = 100
var alisa_atk = 100
var alisa_def = 100
var alisa_spd = 100

var lina_hp = 100
var lina_atk = 100
var lina_def = 100
var lina_spd = 100

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(_delta):
	if Input.is_action_just_pressed("FullScreen") and windowed:
		DisplayServer.window_set_mode(4)
		windowed = false
	else: if Input.is_action_just_pressed("FullScreen") and not windowed:
		DisplayServer.window_set_mode(2)
		windowed = true
		
	apply_item_stats()

func apply_item_stats():
	alisa_hp = alisa_base_hp + alisa_equipped_item.hp_value
	alisa_atk = alisa_base_atk + alisa_equipped_item.atk_value
	alisa_def = alisa_base_def + alisa_equipped_item.def_value
	alisa_spd = alisa_base_spd + alisa_equipped_item.spd_value
	
	lina_hp = lina_base_hp + lina_equipped_item.hp_value
	lina_atk = lina_base_atk + lina_equipped_item.atk_value
	lina_def = lina_base_def + lina_equipped_item.def_value
	lina_spd = lina_base_spd + lina_equipped_item.spd_value
