extends ParentLevel

signal esc_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	$GuideAnim.play("guide_anim")
	await BattleScene.battle_over
	await Dialogue.dialogue_finished
	if Globals.language == "ENG":
		var tween1 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween1.tween_property($Pause, "modulate", Color(1.0, 1.0, 1.0), 1)
		await PauseMenu.menu_opened
		var tween2 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween2.tween_property($Pause, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
	if Globals.language == "RUS":
		var tween1 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween1.tween_property($PauseRU, "modulate", Color(1.0, 1.0, 1.0), 1)
		await PauseMenu.menu_opened
		var tween2 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween2.tween_property($PauseRU, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
	

func esc():
	if Input.is_action_just_pressed("Pause"):
		esc_pressed.emit()
