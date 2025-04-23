extends CanvasLayer

var music_bus_index: int 
var sfx_bus_index: int 

var paused:bool = false
var pause_enabled:bool = false
enum locations
{
	BASE, SETTINGS, CHARACTERS, CHARACTERS_ALISA, CHARACTERS_LINA
}
var currentLocation

@onready var anim = $AnimationPlayer
@onready var anim2 = $AnimationPlayer2
@onready var alisa_item_select = $CharacterMenu/AlisaMenu/ItemSelect
@onready var alisa_skill_select = $CharacterMenu/AlisaMenu/SkillSelect
@onready var alisa_menu = $CharacterMenu/AlisaMenu
@onready var lina_item_select = $CharacterMenu/LinaMenu/ItemSelect
@onready var lina_skill_select = $CharacterMenu/LinaMenu/SkillSelect
@onready var lina_menu = $CharacterMenu/LinaMenu
@onready var characters_arrows = $CharacterMenu/CharactersArrows
@onready var music_slider = $Settings/MusicSlider
@onready var sfx_slider = $Settings/SFXSlider

func _ready() -> void:
	currentLocation = locations.BASE
	anim2.play("arrows blink")
	
	music_bus_index = AudioServer.get_bus_index("Music")
	music_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(music_bus_index)
	)
	
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	sfx_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(sfx_bus_index)
	)
	

func _process(delta):
	if not Dialogue.is_dialogue_active:
		pause()
	
	if pause_enabled and paused and not anim.is_playing():
		state_control()
	
	
	
func state_control():
	if currentLocation == locations.BASE:
		if Input.is_action_just_pressed("down"):
			anim.play("go to characters")
			anim2.play("characters arrows blink")
			currentLocation = locations.CHARACTERS
		if Input.is_action_just_pressed("up"):
			anim.play("go to settings")
			settings_menu_select()
			currentLocation = locations.SETTINGS
	
	if currentLocation == locations.CHARACTERS:
		if Input.is_action_just_pressed("right"):
			anim.play("open lina")
			lina_menu_select()
			currentLocation = locations.CHARACTERS_LINA
		if Input.is_action_just_pressed("back"):
			anim.play_backwards("go to characters")
			anim2.play("arrows blink")
			currentLocation = locations.BASE
		if Input.is_action_just_pressed("left"):
			anim.play("open alisa")
			alisa_menu_select()
			currentLocation = locations.CHARACTERS_ALISA
	
	if currentLocation == locations.CHARACTERS_ALISA:
		if Input.is_action_just_pressed("back"):
			anim.play_backwards("open alisa")
			alisa_menu_deselect()
			currentLocation = locations.CHARACTERS
	
	if currentLocation == locations.CHARACTERS_LINA:
		if Input.is_action_just_pressed("back"):
			anim.play_backwards("open lina")
			lina_menu_deselect()
			currentLocation = locations.CHARACTERS
			
	if currentLocation == locations.SETTINGS:
		if Input.is_action_just_pressed("back"):
			anim.play_backwards("go to settings")
			settings_menu_deselect()
			currentLocation = locations.BASE
			
func reset():
	currentLocation = locations.BASE
	offset = Vector2(0,0)
	anim.play_backwards("open alisa")
	anim2.play("arrows blink")
	alisa_menu_deselect()
	lina_menu_deselect()

func alisa_menu_select():
	characters_arrows.visible = false
	await get_tree().create_timer(0.5).timeout
	alisa_menu.visible = true
	alisa_item_select.process_mode = Node.PROCESS_MODE_ALWAYS
	alisa_skill_select.process_mode = Node.PROCESS_MODE_ALWAYS
	alisa_skill_select.grab_focus()
	
func alisa_menu_deselect():
	alisa_menu.visible = false
	alisa_item_select.process_mode = Node.PROCESS_MODE_DISABLED
	alisa_skill_select.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.5).timeout
	anim2.play("characters arrows blink")
	characters_arrows.visible = true
	
func lina_menu_select():
	characters_arrows.visible = false
	await get_tree().create_timer(0.5).timeout
	lina_menu.visible = true
	lina_item_select.process_mode = Node.PROCESS_MODE_ALWAYS
	lina_skill_select.process_mode = Node.PROCESS_MODE_ALWAYS
	lina_skill_select.grab_focus()
	
func lina_menu_deselect():
	lina_menu.visible = false
	lina_item_select.process_mode = Node.PROCESS_MODE_DISABLED
	lina_skill_select.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.5).timeout
	anim2.play("characters arrows blink")
	characters_arrows.visible = true

func settings_menu_select():
	music_slider.process_mode = Node.PROCESS_MODE_ALWAYS
	sfx_slider.process_mode = Node.PROCESS_MODE_ALWAYS
	music_slider.grab_focus()
	
func settings_menu_deselect():
	music_slider.process_mode = Node.PROCESS_MODE_DISABLED
	sfx_slider.process_mode = Node.PROCESS_MODE_DISABLED


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		music_bus_index,
		linear_to_db(value)
	)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		sfx_bus_index,
		linear_to_db(value)
	)

func pause():
	if Input.is_action_just_pressed("Pause") and pause_enabled and not paused:
		paused = true
		get_tree().paused = true
		$".".visible = true
		anim2.play("arrows blink")
	elif Input.is_action_just_pressed("Pause") and paused:
		paused = false
		get_tree().paused = false
		$".".visible = false
		reset()
		
