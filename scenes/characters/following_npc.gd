extends NPCParent

@onready var nav = $NavigationAgent3D
@onready var interaction_area = $InteractionArea


var direction: Vector3

var follow_speed = 0.5
var follow_accel = 1
var target 

func _ready() -> void:
	target = get_tree().get_root().find_child("Player",true,false)
	Dialogue.dialogue_started.connect(_on_dialogue_started)
	

func _process(delta: float) -> void:
	if not Dialogue.is_dialogue_active:
		if target.currentState == states.RUN:
			follow_speed = 0.8
			currentState = states.RUN
		else:
			follow_speed = 0.5
			currentState = states.WALK
		nav.target_position = target.global_position
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		if nav.is_navigation_finished():
			currentState = states.IDLE
			nav.target_desired_distance = 0.4
			idle_anim()
			return
		nav.target_desired_distance = 0.2
		velocity = velocity.lerp(direction * follow_speed, follow_accel)
		walking_anim()
		move_and_slide()
		
	
func walking_anim():
	if velocity.x < 0:
		currentDirection = directions.LEFT
	if velocity.x > 0 :
		currentDirection = directions.RIGHT
	if velocity.z < 0 and abs(velocity.z) > abs(velocity.x):
		currentDirection = directions.UP
	if velocity.z > 0 and abs(velocity.z) > abs(velocity.x):
		currentDirection = directions.DOWN
	if currentState == states.RUN:
		match currentDirection:
			directions.UP: anim.play('run_up')
			directions.DOWN: anim.play('run_down')
			directions.RIGHT: anim.play('run_right')
			directions.LEFT: anim.play('run_left')
	if currentState == states.WALK:
		match currentDirection:
			directions.UP: anim.play('go_up')
			directions.DOWN: anim.play('go_down')
			directions.RIGHT: anim.play('go_right')
			directions.LEFT: anim.play('go_left')

func idle_anim():
	anim.stop()
	if direction.x < 0:
		currentDirection = directions.LEFT
	if direction.x > 0 :
		currentDirection = directions.RIGHT
	if direction.z < 0 and abs(direction.z) > abs(direction.x):
		currentDirection = directions.UP
	if direction.z > 0 and abs(direction.z) > abs(direction.x):
		currentDirection = directions.DOWN
	match currentDirection:
			directions.UP: sprite.frame = 3
			directions.DOWN: sprite.frame = 0
			directions.LEFT: sprite.frame = 6
			directions.RIGHT: sprite.frame = 9

func deactivate():
	interaction_area.monitoring = false
	interaction_area.monitorable = false
	sprite.visible = false

func activate():
	interaction_area.monitoring = true
	interaction_area.monitorable = true
	sprite.visible = true
	
func _on_dialogue_started():
	anim.stop()
	if direction.x < 0:
		currentDirection = directions.LEFT
	if direction.x > 0 :
		currentDirection = directions.RIGHT
	if direction.z < 0 and abs(direction.z) > abs(direction.x):
		currentDirection = directions.UP
	if direction.z > 0 and abs(direction.z) > abs(direction.x):
		currentDirection = directions.DOWN
	match currentDirection:
			directions.UP: sprite.frame = 3
			directions.DOWN: sprite.frame = 0
			directions.LEFT: sprite.frame = 6
			directions.RIGHT: sprite.frame = 9
