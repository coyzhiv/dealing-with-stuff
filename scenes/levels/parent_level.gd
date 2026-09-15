extends Node3D

class_name ParentLevel
@export var location: String
@export var variant: int

func _ready() -> void:
	Globals.current_scene = scene_file_path
	if Soundtrack.is_playing:
		Soundtrack.change_soundtrack(location, variant)
	if not Soundtrack.is_playing:
		Soundtrack.play(location, variant)
	PauseMenu.pause_enabled = true
	var follow = get_tree().get_root().find_child("Follow",true,false)
	if follow != null:
		if not Globals.is_alisa_in_party:
			follow.deactivate()
		if Globals.is_alisa_in_party:
			follow.activate()
