extends Node

var starting_dialogue_used = false
var dishes_dialogue_used = false
var washing_machine_dialogue_used = false
var alisa_saw_room = false
var trash_dialogue_used = false
var first_fight = true

var tv_used = false
var fridge_used = false

var dishes_state = 1
var clothes_state = 1
var trash_state = 1

var save_file = ConfigFile.new()
const save_file_path = "user://interaction_save.ini"

signal save_loaded

func _ready():
	
	var test_enter = ""
	if test_enter == "after_start":
		starting_dialogue_used = true

	if test_enter == "after_dishes":
		starting_dialogue_used = true
		dishes_dialogue_used = true
		dishes_state = 2
		Globals.is_alisa_in_party = true
	if test_enter == "after_washing":
		starting_dialogue_used = true
		dishes_dialogue_used = true
		washing_machine_dialogue_used = true
		dishes_state = 2
		clothes_state = 2
		Globals.is_alisa_in_party = true
		first_fight = false
	if test_enter == "after_trash":
		starting_dialogue_used = true
		dishes_dialogue_used = true
		washing_machine_dialogue_used = true
		alisa_saw_room = true
		trash_dialogue_used = true
		dishes_state = 2
		clothes_state = 2
		trash_state = 2
		Globals.is_alisa_in_party = true
		first_fight = false

func save():
	save_file.set_value("InteractionMemory", "starting_dialogue_used", starting_dialogue_used)
	save_file.set_value("InteractionMemory", "dishes_dialogue_used", dishes_dialogue_used)
	save_file.set_value("InteractionMemory", "washing_machine_dialogue_used", washing_machine_dialogue_used)
	save_file.set_value("InteractionMemory", "alisa_saw_room", alisa_saw_room)
	save_file.set_value("InteractionMemory", "trash_dialogue_used", trash_dialogue_used)
	
	save_file.set_value("InteractionMemory", "tv_used", tv_used)
	save_file.set_value("InteractionMemory", "fridge_used", fridge_used)

	save_file.set_value("InteractionMemory", "dishes_state", dishes_state)
	save_file.set_value("InteractionMemory", "clothes_state", clothes_state)
	save_file.set_value("InteractionMemory", "trash_state", trash_state)
	save_file.set_value("InteractionMemory", "first_fight", first_fight)
	save_file.save(save_file_path)
	
func save_load():
	save_file.load(save_file_path)
	starting_dialogue_used = save_file.get_value("InteractionMemory", "starting_dialogue_used")
	dishes_dialogue_used = save_file.get_value("InteractionMemory", "dishes_dialogue_used")
	washing_machine_dialogue_used = save_file.get_value("InteractionMemory", "washing_machine_dialogue_used")
	alisa_saw_room = save_file.get_value("InteractionMemory", "alisa_saw_room")
	trash_dialogue_used = save_file.get_value("InteractionMemory", "trash_dialogue_used")
	tv_used = save_file.get_value("InteractionMemory", "tv_used")
	fridge_used = save_file.get_value("InteractionMemory", "fridge_used")
	dishes_state = save_file.get_value("InteractionMemory", "dishes_state")
	clothes_state = save_file.get_value("InteractionMemory", "clothes_state")
	trash_state = save_file.get_value("InteractionMemory", "trash_state")
	first_fight = save_file.get_value("InteractionMemory", "first_fight")
	save_loaded.emit()

func reset():
	starting_dialogue_used = false
	dishes_dialogue_used = false
	washing_machine_dialogue_used = false
	alisa_saw_room = false
	trash_dialogue_used = false

	tv_used = false
	fridge_used = false

	dishes_state = 1
	clothes_state = 1
	trash_state = 1
