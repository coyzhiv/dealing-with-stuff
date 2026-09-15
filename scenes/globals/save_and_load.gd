extends Node

var save_file = ConfigFile.new()
const save_file_path = "user://globals_save.ini"


func save():
	InteractionMemory.save()
	Globals.save()
		
	
func save_load(transition_status):
	Globals.save_load()
	InteractionMemory.save_load()
	Transition.load_save(Globals.current_scene, Globals.player_pos, Globals.direction, Globals.location, Globals.sound_id, transition_status)
	
