extends Node

var save_file = ConfigFile.new()
var dir = DirAccess.open("user://")
const save_file_path = "user://globals_save.ini"

@onready var new_game_button = $SubViewport/Menu/NewGame
@onready var continue_button = $SubViewport/Menu/Continue
@onready var settings_button = $SubViewport/Menu/Settings



var music_bus_index:int
var sfx_bus_index:int
var in_settings:bool = false

signal confirm_pressed

func _ready() -> void:
	save_file.load(save_file_path)
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	
	if FileAccess.file_exists(save_file_path):
		AudioServer.set_bus_volume_db(
			sfx_bus_index,
			linear_to_db(save_file.get_value("Variables", "sfx_value"))
		)
		AudioServer.set_bus_volume_db(
			music_bus_index,
			linear_to_db(save_file.get_value("Variables", "music_value"))
		)
	
	$SubViewport/Menu/SettingsMenu/SFXSlider.value = db_to_linear(
		AudioServer.get_bus_volume_db(music_bus_index)
	)
	$SubViewport/Menu/SettingsMenu/MusicSlider.value = db_to_linear(
		AudioServer.get_bus_volume_db(sfx_bus_index)
	)
	new_game_button.text = tr("NG_BUTTON")
	continue_button.text = tr("CONTINUE_BUTTON")
	settings_button.text = tr("SETTINGS_BUTTON")
	$SubViewport/Menu/SettingsMenu/SFXLabel.text = tr("SFX")
	$SubViewport/Menu/SettingsMenu/MusicLabel.text = tr("MUSIC")
	$SubViewport/Menu/SettingsMenu/Langage.text = tr("LANGUAGE")
	Globals.reset()
	InteractionMemory.reset()
	if not FileAccess.file_exists(save_file_path):
		continue_button.disabled = true
		continue_button.focus_mode = 0
		
	new_game_button.process_mode = Node.PROCESS_MODE_DISABLED
	continue_button.process_mode = Node.PROCESS_MODE_DISABLED
	settings_button.process_mode = Node.PROCESS_MODE_DISABLED
	new_game_button.grab_focus()
	$Intro/AnimationPlayer.play('intro_down', -1)
	
	
	await $Intro/AnimationPlayer.animation_finished
	new_game_button.process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_button.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if new_game_button.process_mode == Node.PROCESS_MODE_ALWAYS and Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("down") or Input.is_action_just_pressed("up") or Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		$TVButtonPress.pitch_scale = randf_range(0.7,1.3)
		$TVButtonPress.play()
	if Input.is_action_just_pressed("confirm"):
		confirm_pressed.emit()
	
	if in_settings:
		if Input.is_action_just_pressed("back"):
			$SubViewport/Menu/SettingsMenu.visible = false
			in_settings = false
			new_game_button.focus_mode = 2
			if FileAccess.file_exists(save_file_path):
				continue_button.focus_mode = 2
			settings_button.focus_mode = 2
			$SubViewport/Menu/SettingsMenu/Russian.focus_mode = 0
			$SubViewport/Menu/SettingsMenu/English.focus_mode = 0
			$SubViewport/Menu/SettingsMenu/SFXSlider.focus_mode = 0
			$SubViewport/Menu/SettingsMenu/MusicSlider.focus_mode = 0
			$SubViewport/Menu/Settings.grab_focus()

func _on_button_pressed() -> void:
	
		Transition.play_simple_transition()
		await get_tree().create_timer(0.3).timeout
		$Guide.visible = true
		await get_tree().create_timer(1).timeout
		await confirm_pressed
		Transition.play_simple_transition(3)
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://scenes/levels/apartament/apartament_room.tscn")
		


func _on_button_2_pressed() -> void:
	if FileAccess.file_exists(save_file_path):
		dir.remove("globals_save.ini")
		dir.remove("interaction_save.ini")


func _on_new_game_pressed() -> void:
	new_game_button.process_mode = Node.PROCESS_MODE_DISABLED
	continue_button.process_mode = Node.PROCESS_MODE_DISABLED
	Transition.play_simple_transition(0.5)
	await get_tree().create_timer(1.3).timeout
	get_tree().change_scene_to_file("res://resourses/sprites/cutscenes/dark_park/dark_park.tscn")
	


func _on_continue_pressed() -> void:
	new_game_button.process_mode = Node.PROCESS_MODE_DISABLED
	continue_button.process_mode = Node.PROCESS_MODE_DISABLED
	SaveAndLoad.save_load(true)


func _on_settings_pressed() -> void:
	$SubViewport/Menu/SettingsMenu.visible = true
	new_game_button.focus_mode = 0
	continue_button.focus_mode = 0
	settings_button.focus_mode = 0
	$SubViewport/Menu/SettingsMenu/Russian.focus_mode = 2
	$SubViewport/Menu/SettingsMenu/English.focus_mode = 2
	$SubViewport/Menu/SettingsMenu/SFXSlider.focus_mode = 2
	$SubViewport/Menu/SettingsMenu/MusicSlider.focus_mode = 2
	$SubViewport/Menu/SettingsMenu/Russian.grab_focus()
	in_settings = true


func _on_russian_pressed() -> void:
	TranslationServer.set_locale("RUS")
	Globals.language = "RUS"
	new_game_button.text = tr("NG_BUTTON")
	continue_button.text = tr("CONTINUE_BUTTON")
	settings_button.text = tr("SETTINGS_BUTTON")
	$SubViewport/Menu/SettingsMenu/SFXLabel.text = tr("SFX")
	$SubViewport/Menu/SettingsMenu/MusicLabel.text = tr("MUSIC")
	$SubViewport/Menu/SettingsMenu/Langage.text = tr("LANGUAGE")
	save_file.set_value("Variables", "language", "RUS")
	save_file.save(save_file_path)


func _on_english_pressed() -> void:
	TranslationServer.set_locale("ENG")
	Globals.language = "ENG"
	new_game_button.text = tr("NG_BUTTON")
	continue_button.text = tr("CONTINUE_BUTTON")
	settings_button.text = tr("SETTINGS_BUTTON")
	$SubViewport/Menu/Confirm.text = tr("CONFIRM")
	$SubViewport/Menu/Cancel.text = tr("CANCEL")
	$SubViewport/Menu/SettingsMenu/SFXLabel.text = tr("SFX")
	$SubViewport/Menu/SettingsMenu/MusicLabel.text = tr("MUSIC")
	$SubViewport/Menu/SettingsMenu/Langage.text = tr("LANGUAGE")
	save_file.set_value("Variables", "language", "ENG")
	save_file.save(save_file_path)





func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		sfx_bus_index,
		linear_to_db(value)
	)
	save_file.set_value("Variables", "music_value", value)
	save_file.save(save_file_path)
	


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		sfx_bus_index,
		linear_to_db(value)
	)
	save_file.set_value("Variables", "sfx_value", value)
	save_file.save(save_file_path)
