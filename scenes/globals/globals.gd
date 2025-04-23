extends Node3D

var windowed: bool = true


func _process(delta):
	if Input.is_action_just_pressed("FullScreen") and windowed:
		DisplayServer.window_set_mode(4)
		windowed = false
	else: if Input.is_action_just_pressed("FullScreen") and not windowed:
		DisplayServer.window_set_mode(2)
		windowed = true
