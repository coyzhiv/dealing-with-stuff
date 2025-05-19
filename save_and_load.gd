extends Node

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_fight_left"):
		save()
	if Input.is_action_just_pressed("left_fight_right"):
		save_load()

func save():
	Globals.save()
	
func save_load():
	Globals.save_load()
	Transition.change_scene(Globals.current_scene, Globals.player_pos, Globals.direction, Globals.location, Globals.sound_id)
