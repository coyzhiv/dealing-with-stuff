extends Area3D

@export var prompt:String
@export var used_memory_id: String
@export var disappear_memory_id: String
@export var body_entering: bool
@export var easy_interact: bool
@export var easy_text: String
@export var condition_state: bool
@export var condition: String

func _ready() -> void:
	if InteractionMemory.get(disappear_memory_id) == true:
		queue_free()

func recieve_interaction():
	if InteractionMemory.get(condition) == condition_state or condition == "":
		if not easy_interact:
			if used_memory_id != "":
				if InteractionMemory.get(used_memory_id) == false:
					Dialogue.start(prompt)
			else:
				Dialogue.start(prompt)
		else:
			if used_memory_id != "":
				if InteractionMemory.get(used_memory_id) == false:
					Dialogue.easy_start(easy_text)
			else:
				Dialogue.easy_start(easy_text)

func _on_body_entered(body: Node3D) -> void:
	if body_entering:
		recieve_interaction()
