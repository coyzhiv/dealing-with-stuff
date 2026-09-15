extends Area3D

@export_group("Dialogue")
@export var prompt:String
@export var prompt_ru:String
@export var used_memory_id: String
@export var disappear_memory_id: String
@export var body_entering: bool
@export var easy_interact: bool
@export var easy_text: String
@export var easy_text_ru: String
@export var condition_state: bool
@export var condition: String

@export_group("ChangeScene")
@export var change_scene:bool = false
@export var file: String
@export var target_position: Vector3
@export var direction: String
@export var location: String
@export var sound_id: int

@export_group("SittingPlace")
@export var sitting_place:bool = false
@export var sit_direction: String
@export var stand_position: Vector3
@export var stand_direction: String

func _ready() -> void:
	if InteractionMemory.get(disappear_memory_id) == true:
		queue_free()

func recieve_interaction():
	if InteractionMemory.get(condition) == condition_state or condition == "":
		if change_scene:
			Transition.change_scene(file, target_position, direction, location, sound_id)
			return
		if sitting_place:
			var player = get_parent().get_parent().find_child("Player", true)
			player.jump(position, sit_direction, stand_position, stand_direction)
			return
		if not easy_interact:
			if used_memory_id != "":
				if InteractionMemory.get(used_memory_id) == false:
					match Globals.language:
						"ENG":Dialogue.start(prompt)
						"RUS":Dialogue.start(prompt_ru)
			else:
				match Globals.language:
					"ENG":Dialogue.start(prompt)
					"RUS":Dialogue.start(prompt_ru)
		else:
			if used_memory_id != "":
				if InteractionMemory.get(used_memory_id) == false:
					match Globals.language:
						"ENG":Dialogue.easy_start(easy_text)
						"RUS":Dialogue.easy_start(easy_text_ru)
			else:
				match Globals.language:
					"ENG":Dialogue.easy_start(easy_text)
					"RUS":Dialogue.easy_start(easy_text_ru)

func _on_body_entered(body: Node3D) -> void:
	if body_entering and not Dialogue.is_dialogue_active:
		recieve_interaction()
