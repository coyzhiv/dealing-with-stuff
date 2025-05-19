extends ParentLevel

func _on_ready():
	if InteractionMemory.dishes_dialogue_used:
		InteractionMemory.alisa_saw_room = true
