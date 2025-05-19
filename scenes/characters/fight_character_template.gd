extends Node3D

@onready var player_sprite = $PlayerSprite
@onready var anim = $AnimationPlayer
var alisa_texture = preload("res://resourses/sprites/characters/alisa.png")
var lina_texture = preload("res://resourses/sprites/characters/lina.png")

signal anim_ended

func init(player):
	if player.id == 0:
		player_sprite.texture = alisa_texture
	if player.id == 1:
		player_sprite.texture = lina_texture

func idle_no_turn():
	anim.play('RESET')

func idle_turn():
	anim.play('ilde_no_turn_old')

func punch_fast():
	anim.play('punch_fast')

func punch_slow():
	anim.play('punch_slow')

func recieve_buff():
	anim.play('recieve_buff')

func recieve_damage():
	anim.play('recieve_damage')

func recieve_ko():
	anim.play('recieve_ko')
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	anim_ended.emit()
