extends ParentLevel

signal back_pressed
signal walk_pressed
signal interact_pressed

func _ready() -> void:
	super()
	if not InteractionMemory.starting_dialogue_used:
		$GuideAnim.play("guide_anim")
		var player = get_tree().get_root().find_child("Player",true, false)
		$InteractionAreas/StartingDialogue.monitoring = false
		$Player/Camera3D.v_offset = 1.4
		player.sitting = true
		$AnimationPlayer.play("sleeping")
		await $AnimationPlayer.animation_finished
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween.tween_property($Player/Camera3D, "v_offset", 0, 3)
		await tween.finished
		$InteractionAreas/StartingDialogue.monitoring = true
		player.ready_to_stand = true
		player.standing_pos = Vector3(-0.315, 0.12, -0.423)
		player.standing_dir = "down"
		await Dialogue.dialogue_finished
		if Globals.language == "ENG":
			var tween1 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
			tween1.tween_property($Control/StandUp, "modulate", Color(1.0, 1.0, 1.0), 1)
			await back_pressed
			var tween2 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
			tween2.tween_property($Control/StandUp, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
			tween2.tween_property($Control/Walk, "modulate", Color(1.0, 1.0, 1.0), 1)
			await walk_pressed
			var tween3 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
			tween3.tween_property($Control/Walk, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
			tween3.tween_property($Control/Interact, "modulate", Color(1.0, 1.0, 1.0), 1)
			await interact_pressed
			var tween4 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
			tween4.tween_property($Control/Interact, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
		if Globals.language == "RUS":
			var tween1 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
			tween1.tween_property($Control/StandUpRU, "modulate", Color(1.0, 1.0, 1.0), 1)
			await back_pressed
			var tween2 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
			tween2.tween_property($Control/StandUpRU, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
			tween2.tween_property($Control/WalkRU, "modulate", Color(1.0, 1.0, 1.0), 1)
			await walk_pressed
			var tween3 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
			tween3.tween_property($Control/WalkRU, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
			tween3.tween_property($Control/InteractRU, "modulate", Color(1.0, 1.0, 1.0), 1)
			await interact_pressed
			var tween4 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
			tween4.tween_property($Control/InteractRU, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
		
func _process(delta: float) -> void:
	input_check()
	
func input_check():
	if Input.is_action_just_pressed("back"):
		back_pressed.emit()
	if Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down") or Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		walk_pressed.emit()
	if Input.is_action_just_pressed("confirm"):
		interact_pressed.emit()
