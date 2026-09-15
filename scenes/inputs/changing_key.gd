extends Node2D

@export var keyboard_input: String
@export var xbox_input: String
@export var ps_input: String

var keyboard_w = preload("res://resourses/sprites/interface/inputs/keyboard/w_key.png")
var keyboard_s = preload("res://resourses/sprites/interface/inputs/keyboard/s_key.png")
var keyboard_a = preload("res://resourses/sprites/interface/inputs/keyboard/a_key.png")
var keyboard_d = preload("res://resourses/sprites/interface/inputs/keyboard/d_key.png")
var keyboard_z = preload("res://resourses/sprites/interface/inputs/keyboard/z_key.png")
var keyboard_x = preload("res://resourses/sprites/interface/inputs/keyboard/x_key.png")
var keyboard_up = preload("res://resourses/sprites/interface/inputs/keyboard/up_arrow_key.png")
var keyboard_down = preload("res://resourses/sprites/interface/inputs/keyboard/down_arrow_key.png")
var keyboard_left = preload("res://resourses/sprites/interface/inputs/keyboard/left_arrow_key.png")
var keyboard_right = preload("res://resourses/sprites/interface/inputs/keyboard/right_arrow_key.png")
var keyboard_esc = preload("res://resourses/sprites/interface/inputs/keyboard/esc_key.png")
var keyboard_shift = preload("res://resourses/sprites/interface/inputs/keyboard/shift_key.png")
var keyboard_battle_left = preload("res://resourses/sprites/interface/keyboard_battle_input_left.png")
var keyboard_battle_right = preload("res://resourses/sprites/interface/keyboard_battle_input_right.png")

var controller_up = preload("res://resourses/sprites/interface/inputs/controller/up_gamepad.png")
var controller_down = preload("res://resourses/sprites/interface/inputs/controller/down_gamepad.png")
var controller_right = preload("res://resourses/sprites/interface/inputs/controller/right_gamepad.png")
var controller_left = preload("res://resourses/sprites/interface/inputs/controller/left_gamepad.png")
var controller_rb = preload("res://resourses/sprites/interface/inputs/controller/rb_button.png")
var controller_lb = preload("res://resourses/sprites/interface/inputs/controller/lb_button.png")
var controller_rt = preload("res://resourses/sprites/interface/inputs/controller/rt_button.png")
var controller_lt = preload("res://resourses/sprites/interface/inputs/controller/lt_button.png")
var controller_start = preload("res://resourses/sprites/interface/inputs/controller/start_button.png")
var controller_battle_left = preload("res://resourses/sprites/interface/gamepad_battle_input_left.png")

var ps_box = preload("res://resourses/sprites/interface/inputs/ps_controller/ps_box_button.png")
var ps_o = preload("res://resourses/sprites/interface/inputs/ps_controller/ps_o_button.png")
var ps_triangle = preload("res://resourses/sprites/interface/inputs/ps_controller/ps_triangle_button.png")
var ps_x = preload("res://resourses/sprites/interface/inputs/ps_controller/ps_x_button.png")
var ps_battle_right = preload("res://resourses/sprites/interface/ps_battle_input_right.png")
var ps_pause = preload("res://resourses/sprites/interface/inputs/ps_controller/pause.png")

var xbox_a = preload("res://resourses/sprites/interface/inputs/xbox_conroller/xbox_a_button.png")
var xbox_b = preload("res://resourses/sprites/interface/inputs/xbox_conroller/xbox_b_button.png")
var xbox_x = preload("res://resourses/sprites/interface/inputs/xbox_conroller/xbox_x_button.png")
var xbox_y = preload("res://resourses/sprites/interface/inputs/xbox_conroller/xbox_y_button.png")
var xbox_battle_right = preload("res://resourses/sprites/interface/xbox_battle_input_right.png")
var xbox_pause = preload("res://resourses/sprites/interface/inputs/xbox_conroller/pause.png")

@onready var key_sprite = $KeySprite

var model = "keyboard"

func _ready():
	get_device()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	set_input_sprite()

func _process(delta: float) -> void:
	pass
	
func _on_joy_connection_changed(_device_id, _connected):
	get_device()

func get_device():
	var device_name := Input.get_joy_name(0)
	if device_name.contains("Xbox"):
		model = "xbox"
	elif device_name.contains("PS"):
		model = "ps"
	elif Input.get_connected_joypads().is_empty():
		model = "keyboard"
	else:
		model = "xbox"
	set_input_sprite()
	
func set_input_sprite():
	if model == "keyboard":
		match keyboard_input:
			'w': key_sprite.texture = keyboard_w
			's': key_sprite.texture = keyboard_s
			'a': key_sprite.texture = keyboard_a
			'd': key_sprite.texture = keyboard_d
			'z': key_sprite.texture = keyboard_z
			'x': key_sprite.texture = keyboard_x
			'up': key_sprite.texture = keyboard_up
			'down': key_sprite.texture = keyboard_down
			'left': key_sprite.texture = keyboard_left
			'right': key_sprite.texture = keyboard_right
			'esc': key_sprite.texture = keyboard_esc
			'shift': key_sprite.texture = keyboard_shift
			'battle_left': key_sprite.texture = keyboard_battle_left
			'battle_right': key_sprite.texture = keyboard_battle_right
	elif model == "xbox":
		match xbox_input:
			'up': key_sprite.texture = controller_up
			'down': key_sprite.texture = controller_down
			'right': key_sprite.texture = controller_right
			'left': key_sprite.texture = controller_left
			'rb': key_sprite.texture = controller_rb
			'lb': key_sprite.texture = controller_lb
			'rt': key_sprite.texture = controller_rt
			'lt': key_sprite.texture = controller_lt
			'start': key_sprite.texture = controller_start
			'battle_left': key_sprite.texture = controller_battle_left
			'a': key_sprite.texture = xbox_a
			'b': key_sprite.texture = xbox_b
			'x': key_sprite.texture = xbox_x
			'y': key_sprite.texture = xbox_y
			'battle_right': key_sprite.texture = xbox_battle_right
			'pause': key_sprite.texture = xbox_pause
			
	elif model == "ps":
		match xbox_input:
			'up': key_sprite.texture = controller_up
			'down': key_sprite.texture = controller_down
			'right': key_sprite.texture = controller_right
			'left': key_sprite.texture = controller_left
			'rb': key_sprite.texture = controller_rb
			'lb': key_sprite.texture = controller_lb
			'rt': key_sprite.texture = controller_rt
			'lt': key_sprite.texture = controller_lt
			'start': key_sprite.texture = controller_start
			'battle_left': key_sprite.texture = controller_battle_left
			'box': key_sprite.texture = ps_box
			'o': key_sprite.texture = ps_o
			'triangle': key_sprite.texture = ps_triangle
			'x': key_sprite.texture = ps_x
			'battle_right': key_sprite.texture = ps_battle_right
			'pause': key_sprite.texture = ps_pause
