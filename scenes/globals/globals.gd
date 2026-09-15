extends Node3D

var windowed: bool = true

var inventory: Array[Items]
var alisa_skill_inventory: Array[Skills]
var lina_skill_inventory: Array[Skills]

var alisa_equipped_item
var alisa_equipped_skills: Array[int]
var lina_equipped_item
var lina_equipped_skills: Array[int] 

const default_inventory: Array[Items] = [preload("res://scenes/globals/items/hair_band.tres"),preload("res://scenes/globals/items/badass_choker.tres")]
const default_alisa_skill_inventory: Array[Skills] = [preload("res://scenes/globals/skills/grind.tres"), preload("res://scenes/globals/skills/hurry.tres"), preload("res://scenes/globals/skills/clear_mind.tres"), preload("res://scenes/globals/skills/concentrate.tres"), preload("res://scenes/globals/skills/brave_up.tres"), preload("res://scenes/globals/skills/procrastinate.tres")]
const default_lina_skill_inventory: Array[Skills] = [preload("res://scenes/globals/skills/grind.tres"), preload("res://scenes/globals/skills/hurry.tres"), preload("res://scenes/globals/skills/clear_mind.tres"), preload("res://scenes/globals/skills/concentrate.tres"), preload("res://scenes/globals/skills/brave_up.tres"), preload("res://scenes/globals/skills/procrastinate.tres")]

const default_alisa_equipped_skills: Array[int] = [0, 2]
const default_lina_equipped_skills: Array[int] = [0, 2]


var is_alisa_in_party = false

var alisa_base_hp = 30
var alisa_base_atk = 10
var alisa_base_def = 10
var alisa_base_spd = 10
var alisa_points = 0
var lina_base_hp = 30
var lina_base_atk = 10
var lina_base_def = 10
var lina_base_spd = 10
var lina_points = 0

var alisa_hp = 40
var alisa_atk = 10
var alisa_def = 10
var alisa_spd = 10

var lina_hp = 40
var lina_atk = 10
var lina_def = 10
var lina_spd = 10

var save_file = ConfigFile.new()
const save_file_path = "user://globals_save.ini"

var player_pos:Vector3
var follow_pos:Vector3
var current_scene:String

var direction:String
var location:String
var sound_id:int

var language:String = "RUS"
var sfx_value
var music_value

signal save_loaded

func _ready():
	save_file.load(save_file_path)
	if FileAccess.file_exists(save_file_path):
		TranslationServer.set_locale(save_file.get_value("Variables", "language"))
		Globals.language = save_file.get_value("Variables", "language")
	else:
		TranslationServer.set_locale("ENG")
		Globals.language = "ENG"
	reset()
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

func save():
	var player = get_tree().get_root().find_child("Player",true,false)
	player_pos = player.position
	var follow = get_tree().get_root().find_child("Follow",true,false)
	follow_pos = follow.position
	
	save_file.set_value("Resourses", "inventory", inventory)
	save_file.set_value("Resourses", "alisa_skill_inventory", alisa_skill_inventory)
	save_file.set_value("Resourses", "lina_skill_inventory" , lina_skill_inventory)
	

	save_file.set_value("Resourses", "alisa_equipped_item" , alisa_equipped_item)
	save_file.set_value("Resourses", "alisa_equipped_skills" , alisa_equipped_skills)
	save_file.set_value("Resourses", "lina_equipped_item" , lina_equipped_item)
	save_file.set_value("Resourses", "lina_equipped_skills" , lina_equipped_skills)

	save_file.set_value("Variables", "is_alisa_in_party", is_alisa_in_party)
	save_file.set_value("Variables", "player_pos", player_pos)
	save_file.set_value("Variables", "direction", direction)
	save_file.set_value("Variables", "follow_pos", follow_pos)
	save_file.set_value("Variables", "current_scene", current_scene)
	save_file.set_value("Variables", "alisa_points", alisa_points)
	save_file.set_value("Variables", "lina_points", lina_points)
	
	save_file.set_value("Variables", "language", language)
	save_file.set_value("Variables", "sfx_value", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))))
	save_file.set_value("Variables", "music_value", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))))
	
	save_file.save(save_file_path)
	
func save_load():
	save_file.load(save_file_path)
	inventory = save_file.get_value("Resourses", "inventory")
	alisa_skill_inventory = save_file.get_value("Resourses", "alisa_skill_inventory")
	lina_skill_inventory = save_file.get_value("Resourses", "lina_skill_inventory")
	alisa_equipped_item = save_file.get_value("Resourses", "alisa_equipped_item")
	alisa_equipped_skills = save_file.get_value("Resourses", "alisa_equipped_skills")
	lina_equipped_item = save_file.get_value("Resourses", "lina_equipped_item")
	lina_equipped_skills = save_file.get_value("Resourses", "lina_equipped_skills")
	is_alisa_in_party = save_file.get_value("Variables", "is_alisa_in_party")
	player_pos = save_file.get_value("Variables", "player_pos")
	direction = save_file.get_value("Variables", "direction") 
	follow_pos = save_file.get_value("Variables", "follow_pos")
	current_scene = save_file.get_value("Variables", "current_scene")
	alisa_points = save_file.get_value("Variables", "alisa_points")
	lina_points = save_file.get_value("Variables", "lina_points")
	language = save_file.get_value("Variables", "language")
	save_loaded.emit()

func reset():
	inventory = default_inventory.duplicate()
	alisa_skill_inventory.clear()
	lina_skill_inventory.clear()
	for i in default_alisa_skill_inventory.size():
		alisa_skill_inventory.append(default_lina_skill_inventory[i].duplicate(true))
	for i in default_lina_skill_inventory.size():
		lina_skill_inventory.append(default_lina_skill_inventory[i].duplicate(true))
	
	alisa_equipped_skills.clear()
	lina_equipped_skills.clear()
	alisa_equipped_item = preload("res://scenes/globals/items/badass_choker.tres")
	alisa_equipped_skills.append(0)
	alisa_equipped_skills.append(3)
	lina_equipped_item = preload("res://scenes/globals/items/hair_band.tres")
	lina_equipped_skills.append(0)
	lina_equipped_skills.append(3)

	is_alisa_in_party = false

	alisa_base_hp = 20
	alisa_base_atk = 10
	alisa_base_def = 10
	alisa_base_spd = 10

	lina_base_hp = 20
	lina_base_atk = 10
	lina_base_def = 10
	lina_base_spd = 10

	alisa_hp = 10
	alisa_atk = 10
	alisa_def = 10
	alisa_spd = 10

	lina_hp = 10
	lina_atk = 10
	lina_def = 10
	lina_spd = 10
