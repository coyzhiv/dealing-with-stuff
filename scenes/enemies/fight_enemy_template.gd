extends Node3D

@onready var anim = $AnimationPlayer
@onready var enemy_sprite = $Sprite3D

signal anim_ended

func init(sprite):
	enemy_sprite.texture = sprite

func idle():
	anim.play('idle')

func punch():
	anim.play('punch')

func recieve_damage():
	anim.play('recieve_damage')

func recieve_ko():
	anim.play('recieve_ko')


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	anim_ended.emit()
