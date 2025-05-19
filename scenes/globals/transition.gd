extends CanvasLayer

@onready var anim = $Control/AnimationPlayer
@onready var tranistion_sound = $"Audio/Переход"
var follow_sprite

func play_battle_trans():
	anim.play("battle_transition")
	
func change_scene(file, pos, direction, location, sound_id):
	print('s')
	Globals.current_scene = file
	Globals.direction = direction
	Globals.location = location
	Globals.sound_id = sound_id
	get_tree().paused = true
	anim.play('simple_transition')
	await get_tree().create_timer(0.3).timeout
	tranistion_sound.play()
	get_tree().change_scene_to_file(file)
	await get_tree().create_timer(0.1).timeout
	
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	var follow = get_tree().get_root().find_child("Follow",true,false)
	if follow != null:
		follow_sprite = follow.find_child("Sprite3D",true,false)
	player.position = pos
	match direction:
			"up": 
				player_sprite.frame = 3
				if follow != null:
					follow.position = Vector3(pos.x, pos.y, pos.z + 0.1)
					follow_sprite.frame = 3
			"down": 
				player_sprite.frame = 0
				if follow != null:
					follow.position = Vector3(pos.x, pos.y, pos.z - 0.1)
					follow_sprite.frame = 0
			"left": 
				player_sprite.frame = 6
				if follow != null:
					follow.position = Vector3(pos.x + 0.1, pos.y, pos.z)
					follow_sprite.frame = 6
			"right": 
				player_sprite.frame = 9
				if follow != null:
					follow.position = Vector3(pos.x - 0.1, pos.y, pos.z)
					follow_sprite.frame = 9
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false

func play_simple_transition():
	anim.play('simple_transition')
