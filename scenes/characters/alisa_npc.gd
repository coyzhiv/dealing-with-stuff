extends NPCParent

@export var should_dissapear: bool

func _ready() -> void:
	if Globals.is_alisa_in_party and should_dissapear:
			queue_free()
