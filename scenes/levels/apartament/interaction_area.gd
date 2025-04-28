extends Area3D

@export var prompt:String

func recieve_interaction():
	Dialogue.start(prompt)
