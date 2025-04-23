extends CharacterBody3D

class_name CharacterParent

#animations
enum directions
{
	UP, DOWN, LEFT, RIGHT
}
var currentDirection 

#moving
enum states
{
	IDLE, WALK, RUN
}
var currentState 
var speed = 0.7


#other scenes
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite3D

signal cutscene_walk_ended()

func _ready():
	Dialogue.dialogue_started.connect(_on_dialogue_started)

func cutscene_walk(walk_direction:Vector2, look_direction:String, length:float, duration: float):
	match look_direction:
		"up": 
			anim.play("go_up")
			currentDirection = directions.UP
		"down": 
			anim.play("go_down")
			currentDirection = directions.DOWN
		"left": 
			anim.play("go_left")
			currentDirection = directions.LEFT
		"right": 
			anim.play("go_right")
			currentDirection = directions.RIGHT
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector3(position.x + walk_direction.x * length, position.y, position.z + walk_direction.y * length), duration)
	await tween.finished
	anim.stop()
	match currentDirection:
		directions.UP: sprite.frame = 3
		directions.DOWN: sprite.frame = 0
		directions.LEFT: sprite.frame = 6
		directions.RIGHT: sprite.frame = 9
	cutscene_walk_ended.emit()
	
func _on_dialogue_started():
	anim.stop()
	match currentDirection:
		directions.UP: sprite.frame = 3
		directions.DOWN: sprite.frame = 0
		directions.LEFT: sprite.frame = 6
		directions.RIGHT: sprite.frame = 9
