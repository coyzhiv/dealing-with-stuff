extends Area3D

@export var file: String
@export var target_position: Vector3
@export var direction: String
@export var location: String
@export var sound_id: int




func _on_body_entered(body: Node3D) -> void:
	Transition.change_scene(file, target_position, direction, location, sound_id)
	
