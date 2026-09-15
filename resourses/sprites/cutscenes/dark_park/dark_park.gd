extends Node3D


func _ready() -> void:
	$ColorRect/Epilogue.text = tr("EPILOGUE")
	$ColorRect/Titile.text = tr("EPILOGUE_TITLE")
	$AudioStreamPlayer.play()
	var tween = get_tree().create_tween()
	tween.stop()
	tween.tween_property($ColorRect/Epilogue, "modulate", Color.WHITE, 0.5)
	tween.play()
	await tween.finished
	tween.stop()
	await get_tree().create_timer(0.9).timeout
	tween.tween_property($ColorRect/Titile, "modulate", Color.WHITE, 0.5)
	tween.play()
	await tween.finished
	tween.stop()
	await get_tree().create_timer(0.5).timeout
	tween.tween_property($ColorRect, "modulate", Color.hex(0xffffff00), 0.6)
	tween.play()
	$AnimationPlayer.play("start_walk", -1, 1)
	await get_tree().create_timer(6.7).timeout
	$AnimationPlayer2.play("initial_turn")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("camera_bob", -1, 0.3)
	await $AnimationPlayer2.animation_finished
	match Globals.language:
		"ENG":Dialogue.start("res://JSON Scripts/Dialogues/Apartament/dark_park_cutscene_dialogue.json")
		"RUS":Dialogue.start("res://JSON Scripts/Dialogues/Apartament/dark_park_cutscene_dialogu_ru.json")
	await Dialogue.dialogue_finished
	Transition.play_simple_transition(0.5)
	await get_tree().create_timer(1.3).timeout
	get_tree().change_scene_to_file("res://scenes/levels/apartament/apartament_room.tscn")
	


func _process(delta: float) -> void:
	pass
