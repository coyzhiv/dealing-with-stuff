extends Node3D

var is_playing = false
var current_location
var current_track

@onready var dark_room = $Apartament/DarkRoom
@onready var light_room = $Apartament/LightRoom

func play(location, variant):
	print("play")
	var tween = get_tree().create_tween()
	if location == "apartament":
		current_location = "apartament"
		if variant == -1:
			current_track = null
			dark_room.volume_db = -60
			light_room.volume_db = -60
			dark_room.play()
			light_room.play()
		if variant == 0:
			current_track = dark_room
			dark_room.volume_db = -60
			light_room.volume_db = -60
			tween.tween_property(dark_room, "volume_db", -5, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			dark_room.play()
			light_room.play()
		if variant == 1:
			current_track = light_room
			dark_room.volume_db = -60
			light_room.volume_db = -60
			tween.tween_property(light_room, "volume_db", -5, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			dark_room.play()
			light_room.play()
	is_playing = true

func stop(location):
	print("stop")
	if location == "apartament":
		dark_room.stop()
		light_room.stop()
	is_playing = false

func mute(duration:float = 1):
	print("mute")
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(current_track, "volume_db", -60, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

func unmute(duration:float = 1):
	print("unmute")
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(current_track, "volume_db", -5, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

func change_soundtrack(location, variant):
	var tween1 = get_tree().create_tween()
	tween1.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var tween2 = get_tree().create_tween()
	tween2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if location == "apartament":
		if variant == 0:
			current_track = dark_room
			tween1.tween_property(dark_room, "volume_db", -5, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			tween2.tween_property(light_room, "volume_db", -60, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	if location == "apartament":
		if variant == 1:
			current_track = light_room
			tween1.tween_property(light_room, "volume_db", -5, 1).set_trans(Tween.TRANS_LINEAR).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			tween2.tween_property(dark_room, "volume_db", -60, 1).set_trans(Tween.TRANS_LINEAR).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
