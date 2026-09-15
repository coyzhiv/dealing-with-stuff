extends CharacterParent

var inputDirection = Vector2.ZERO
var gravity = 10
var can_interact = false
var interactable_area:Area3D
@export var sitting:bool = false
@export var ready_to_stand:bool = false
var standing_pos:Vector3
var standing_dir:String

@onready var interact_area = $InteractArea
@onready var interact_label = $InteractLabel

signal cancel_pressed

func _ready():
	$QueAnim.play("que")
	$InteractLabel/Label.text = tr("INTERACT")
	interact_label.visible = false
	can_interact = false

func _process(delta):
	if Input.is_action_just_pressed("back") and ready_to_stand and not Dialogue.is_dialogue_active:
		stand_up()
	if not Dialogue.is_dialogue_active and not sitting:
		move()
		animate()
		applies(delta)
		interact()
		move_and_slide()

		
		
		
#move inputs
func move():
	inputDirection = Input.get_vector("left", "right", "up", "down")
	if inputDirection != Vector2.ZERO:
		currentState = states.WALK
		speed = 0.7
		if Input.is_action_pressed("shift"):
			currentState = states.RUN
			speed = 1.3
		if Input.is_action_pressed("stop"):
			currentState = states.IDLE
			speed = 0.0
	else: currentState = states.IDLE
	velocity.x = inputDirection.x * speed
	velocity.z = inputDirection.y * speed
	
#animations
func animate():
	
	if inputDirection.y > 0:
		currentDirection = directions.DOWN
	if inputDirection.y < 0:
		currentDirection = directions.UP
	if inputDirection.x > 0:
		currentDirection = directions.RIGHT
	if inputDirection.x < 0:
		currentDirection = directions.LEFT
	
	if currentState == states.WALK:
		match currentDirection:
			directions.UP: anim.play("go_up")
			directions.DOWN: anim.play("go_down")
			directions.LEFT: anim.play("go_left")
			directions.RIGHT: anim.play("go_right")
			
	if currentState == states.RUN:
		match currentDirection:
			directions.UP: anim.play("run_up")
			directions.DOWN: anim.play("run_down")
			directions.LEFT: anim.play("run_left")
			directions.RIGHT: anim.play("run_right")
			
	if currentState == states.IDLE:
		anim.stop()
		match currentDirection:
			directions.UP: sprite.frame = 3
			directions.DOWN: sprite.frame = 0
			directions.LEFT: sprite.frame = 6
			directions.RIGHT: sprite.frame = 9
		
func applies(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

func interact():
	
	
	match currentDirection:
			directions.UP: interact_area.position = $InteractAreaPoints/Up.position
			directions.DOWN: interact_area.position = $InteractAreaPoints/Down.position
			directions.LEFT: interact_area.position = $InteractAreaPoints/Left.position
			directions.RIGHT: interact_area.position = $InteractAreaPoints/Right.position
	if can_interact:
		if Input.is_action_just_pressed("confirm"):
			var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property($Sprite3D2, "scale", Vector3(0.0, 0.0, 0.0), 0.2)
			currentState == states.IDLE
			anim.stop()
			match currentDirection:
				directions.UP: sprite.frame = 3
				directions.DOWN: sprite.frame = 0
				directions.LEFT: sprite.frame = 6
				directions.RIGHT: sprite.frame = 9
			interact_label.visible = false
			interactable_area.recieve_interaction()

func jump(pos,dir, stand_pos, stand_dir):
	
	anim.stop()
	sitting = true
	standing_pos = stand_pos
	standing_dir = stand_dir
	var jump_tween1 = get_tree().create_tween()
	var jump_tween2 = get_tree().create_tween()
	jump_tween1.set_trans(Tween.TRANS_QUAD)
	var jump_tween3 = get_tree().create_tween()
	jump_tween3.set_trans(Tween.TRANS_QUAD)
	jump_tween2.set_trans(Tween.TRANS_QUAD)
	jump_tween2.set_ease(Tween.EASE_IN_OUT)
	jump_tween3.set_ease(Tween.EASE_IN_OUT)
	jump_tween1.tween_property($".", "position:y", pos.y+0.1, 0.2)
	jump_tween2.tween_property($".", "position:z", pos.z, 0.4)
	jump_tween3.tween_property($".", "position:x", pos.x, 0.4)
	jump_tween1.chain().tween_property($".", "position:y", pos.y, 0.2)
	await get_tree().create_timer(0.2).timeout
	match dir:
		"down":
			sprite.frame = 0
			currentDirection = directions.DOWN
		"up":
			sprite.frame = 3
			currentDirection = directions.UP
		"left":
			sprite.frame = 6
			currentDirection = directions.LEFT
		"right":
			sprite.frame = 9
			currentDirection = directions.RIGHT
	await jump_tween1.finished
	ready_to_stand = true
	

func stand_up():
	ready_to_stand = false
	var standup_tween1 = get_tree().create_tween()
	var standup_tween2 = get_tree().create_tween()
	standup_tween2.set_trans(Tween.TRANS_QUAD)
	var standup_tween3 = get_tree().create_tween()
	standup_tween3.set_trans(Tween.TRANS_QUAD)
	standup_tween1.set_trans(Tween.TRANS_QUAD)
	standup_tween2.set_ease(Tween.EASE_IN_OUT)
	standup_tween3.set_ease(Tween.EASE_IN_OUT)
	standup_tween1.tween_property($".", "position:y", standing_pos.y+0.1, 0.2)
	standup_tween2.tween_property($".", "position:z", standing_pos.z, 0.4)
	standup_tween3.tween_property($".", "position:x", standing_pos.x, 0.4)
	standup_tween1.chain().tween_property($".", "position:y", standing_pos.y, 0.2)
	await get_tree().create_timer(0.2).timeout
	match standing_dir:
		"down":
			sprite.frame = 0
			currentDirection = directions.DOWN
		"up":
			sprite.frame = 3
			currentDirection = directions.UP
		"left":
			sprite.frame = 6
			currentDirection = directions.LEFT
		"right":
			sprite.frame = 9
			currentDirection = directions.RIGHT
	await standup_tween1.finished
	sitting = false

func _on_interact_area_area_entered(area: Area3D) -> void:
	if InteractionMemory.get(area.condition) == area.condition_state or area.condition == "" and not sitting:
		if area.used_memory_id != "" and not area.body_entering:
			if InteractionMemory.get(area.used_memory_id) == false:
				var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property($Sprite3D2, "scale", Vector3(0.5, 0.5, 0.5), 0.2)
				if area.has_method('recieve_interaction') and not Dialogue.is_dialogue_active:
					can_interact = true
					interactable_area = area
		elif not area.body_entering:
			var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property($Sprite3D2, "scale", Vector3(0.5, 0.5, 0.5), 0.2)
			if area.has_method('recieve_interaction') and not Dialogue.is_dialogue_active:
					can_interact = true
					interactable_area = area

func _on_interact_area_area_exited(area: Area3D) -> void:
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite3D2, "scale", Vector3(0.0, 0.0, 0.0), 0.2)
	can_interact = false
