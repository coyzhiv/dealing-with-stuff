extends CharacterParent

var inputDirection = Vector2.ZERO
var gravity = 10
var can_interact = false
var interactable_area:Area3D

@onready var interact_area = $InteractArea

func _physics_process(delta):
	if not Dialogue.is_dialogue_active:
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
			interactable_area.recieve_interaction()


func _on_interact_area_area_entered(area: Area3D) -> void:
	if area.has_method('recieve_interaction') and not Dialogue.is_dialogue_active:
		can_interact = true
		interactable_area = area


func _on_interact_area_area_exited(area: Area3D) -> void:
	can_interact = false
