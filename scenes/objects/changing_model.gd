extends Node3D

@onready var state1 = $State1
@onready var state2 = $State2
@onready var state3 = $State3
var current_state:int
@export var state_promt: String

func _ready():
	change_state(InteractionMemory.get(state_promt))

func change_state(id):
	match id:
		1:
			state1.visible = true
			state2.visible = false
			state3.visible = false
		2:
			state1.visible = false
			state2.visible = true
			state3.visible = false
		3:
			state1.visible = false
			state2.visible = false
			state3.visible = true
