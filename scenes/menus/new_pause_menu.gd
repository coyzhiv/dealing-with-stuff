extends CanvasLayer

var save_file = ConfigFile.new()
var dir = DirAccess.open("user://")
const save_file_path = "user://globals_save.ini"

var paused:bool = false
var pause_enabled:bool = false
enum locations
{
	BASE, SETTINGS, CHARACTERS_ALISA, CHARACTERS_LINA, SAVES
}
var currentLocation

var music_bus_index: int 
var sfx_bus_index: int 
var shift_hold_progress: float = 0

var no_upgrade = false

var alisa_skill_select_index = -1
var alisa_item_select_index = -1
var lina_skill_select_index = -1
var lina_item_select_index = -1

var alisa_skill_selected_old
var alisa_item_selected_old
var lina_skill_selected_old
var lina_item_selected_old

signal alisa_item_select_changed(index)
signal alisa_skill_select_changed(index)

signal lina_item_select_changed(index)
signal lina_skill_select_changed(index)

signal menu_opened

@onready var anim = $AnimationPlayer
@onready var anim2 = $FogAnimation
@onready var camera_bob_anim = $CameraBobAnimtion

@onready var alisa_item_select = $CharacterMenu/AlisaMenu/ItemSelect
@onready var alisa_skill_select = $CharacterMenu/AlisaMenu/SkillSelect
@onready var alisa_menu = $CharacterMenu/AlisaMenu
@onready var alisa_hp = $CharacterMenu/AlisaMenu/HP
@onready var alisa_atk = $CharacterMenu/AlisaMenu/ATK
@onready var alisa_def = $CharacterMenu/AlisaMenu/DEF
@onready var alisa_spd = $CharacterMenu/AlisaMenu/SPD

@onready var lina_item_select = $CharacterMenu/LinaMenu/ItemSelect
@onready var lina_skill_select = $CharacterMenu/LinaMenu/SkillSelect
@onready var lina_menu = $CharacterMenu/LinaMenu
@onready var lina_hp = $CharacterMenu/LinaMenu/HP
@onready var lina_atk = $CharacterMenu/LinaMenu/ATK
@onready var lina_def = $CharacterMenu/LinaMenu/DEF
@onready var lina_spd = $CharacterMenu/LinaMenu/SPD


@onready var music_slider = $Settings/MusicSlider
@onready var sfx_slider = $Settings/SFXSlider

@onready var info = $CharacterMenu/Info
@onready var info_title = $CharacterMenu/Info/Title
@onready var info_desc = $CharacterMenu/Info/Description
@onready var info_icon = $CharacterMenu/Info/Icon
@onready var info_power = $CharacterMenu/Info/PowerLabel
@onready var info_insight = $CharacterMenu/Info/InsightLabel
@onready var info_upgrade = $CharacterMenu/Info/UpgradeCost

@onready var cam = $SubViewportContainer/SubViewport/Camera3D

@onready var menu_woosh = $Audio/MenuChangeWhoosh
@onready var background_sound = $Audio/Background
@onready var change_sound = $"Audio/КарандашСтена"
@onready var select_sound = $"Audio/СтукСтена"

func _ready() -> void:
	
	$CharacterMenu/Info/UpgradeLabel.text = tr("UPGRADE")
	music_slider.process_mode = Node.PROCESS_MODE_ALWAYS
	sfx_slider.process_mode = Node.PROCESS_MODE_ALWAYS
	currentLocation = locations.BASE
	
	music_bus_index = AudioServer.get_bus_index("Music")
	music_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(music_bus_index)
	)
	
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	sfx_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(sfx_bus_index)
	)
	music_slider.process_mode = Node.PROCESS_MODE_DISABLED
	sfx_slider.process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta):
	
	if Input.is_action_pressed("shift") and not no_upgrade:
		if (alisa_skill_select_index != -1 and alisa_skill_select.has_focus()) or (lina_skill_select_index != -1 and lina_skill_select.has_focus()):
			shift_hold_progress += 150 * delta
			shift_hold_progress = clamp(shift_hold_progress, 0, 100)
	else:
		shift_hold_progress = 0
	$CharacterMenu/Info/ProgressBar.value = shift_hold_progress
	if shift_hold_progress == 100:
		upgrade()
		shift_hold_progress = 0
		no_upgrade = true
		await get_tree().create_timer(0.5).timeout
		no_upgrade = false
	if not Dialogue.is_dialogue_active:
		pause()
	
	if pause_enabled and paused and not anim.is_playing():
		state_control()
		select_change_check()

func reset():
	currentLocation = locations.BASE
	anim.play("RESET")
	camera_bob_anim.play("RESET")
	alisa_menu_deselect()
	lina_menu_deselect()
	save_menu_deselect()

func pause():
	if Input.is_action_just_pressed("Pause") and pause_enabled and not paused  and not anim2.is_playing():
		menu_opened.emit()
		$Settings/Label2.text = tr("MUSIC")
		$Settings/Label.text = tr("SFX")
		$SaveMenu/SaveButton.text = tr("SAVE")
		$SaveMenu/LoadButton.text = tr("LOAD")
		Soundtrack.mute()
		menu_woosh.play()
		paused = true
		get_tree().paused = true
		if Globals.is_alisa_in_party:
			$SubViewportContainer/SubViewport/AlisaAnim.visible = true
		else:
			$SubViewportContainer/SubViewport/AlisaAnim.visible = false
		anim2.play("fog_left")
		camera_bob_anim.play("camera_bob")
		await get_tree().create_timer(0.28).timeout
		background_sound.play()
		$CharacterMenu.visible = true
		$Settings.visible = true
		$SubViewportContainer.visible = true
		$SaveMenu.visible = true
		$SubViewportContainer/SubViewport/DirectionalLight3D.visible = true
		
	elif Input.is_action_just_pressed("Pause") and paused and not anim2.is_playing():
		Soundtrack.unmute()
		menu_woosh.play()
		paused = false
		anim2.play_backwards("fog_left")
		await get_tree().create_timer(0.28).timeout
		camera_bob_anim.play_backwards("go to saves")
		$SubViewportContainer.visible = false
		$CharacterMenu.visible = false
		$Settings.visible = false
		$SaveMenu.visible = false
		$SubViewportContainer/SubViewport/DirectionalLight3D.visible = false
		get_tree().paused = false
		await get_tree().create_timer(0.22).timeout
		background_sound.stop()
		reset()

func upgrade():
	if alisa_skill_select_index != -1 and alisa_skill_select.has_focus() and Globals.alisa_skill_inventory[alisa_skill_select_index].upgrade < Globals.alisa_skill_inventory[alisa_skill_select_index].steps.size() and Globals.alisa_skill_inventory[alisa_skill_select_index].price[Globals.alisa_skill_inventory[alisa_skill_select_index].upgrade] <= Globals.alisa_points:
		select_sound.play()
		Globals.alisa_points -= Globals.alisa_skill_inventory[alisa_skill_select_index].price[Globals.alisa_skill_inventory[alisa_skill_select_index].upgrade]
		Globals.alisa_skill_inventory[alisa_skill_select_index].upgrade += 1
		Globals.alisa_skill_inventory[alisa_skill_select_index].value += Globals.alisa_skill_inventory[alisa_skill_select_index].steps[Globals.alisa_skill_inventory[alisa_skill_select_index].upgrade-1]
		info_insight.text = "Insight: " +  str(Globals.alisa_skill_inventory[alisa_skill_select_index].upgrade) + "/" + str(Globals.alisa_skill_inventory[alisa_skill_select_index].steps.size())
		info_power.text = "Power: " + str(Globals.alisa_skill_inventory[alisa_skill_select_index].value + Globals.alisa_skill_inventory[alisa_skill_select_index].upgrade)
		if Globals.alisa_skill_inventory[alisa_skill_select_index].upgrade < Globals.alisa_skill_inventory[alisa_skill_select_index].steps.size():
			info_upgrade.text = str(Globals.alisa_points) + "/" + str(Globals.alisa_skill_inventory[alisa_skill_select_index].price[Globals.alisa_skill_inventory[alisa_skill_select_index].upgrade])
			if Globals.alisa_points < Globals.alisa_skill_inventory[alisa_skill_select_index].price[Globals.alisa_skill_inventory[alisa_skill_select_index].upgrade]:
				info_upgrade.modulate = Color.RED
			else:
				info_upgrade.modulate = Color.WHITE
		else:
			info_upgrade.text = "MAX"
	elif alisa_skill_select_index != -1 and alisa_skill_select.has_focus() and Globals.alisa_skill_inventory[alisa_skill_select_index].upgrade < Globals.alisa_skill_inventory[alisa_skill_select_index].steps.size() and Globals.alisa_skill_inventory[alisa_skill_select_index].price[Globals.alisa_skill_inventory[alisa_skill_select_index].upgrade] > Globals.alisa_points:
		$Audio/SpellIsNot.play()
	if lina_skill_select_index != -1 and lina_skill_select.has_focus() and Globals.lina_skill_inventory[lina_skill_select_index].upgrade < Globals.lina_skill_inventory[lina_skill_select_index].steps.size() and Globals.lina_skill_inventory[lina_skill_select_index].price[Globals.lina_skill_inventory[lina_skill_select_index].upgrade] <= Globals.lina_points:
		select_sound.play()
		Globals.lina_points -= Globals.lina_skill_inventory[lina_skill_select_index].price[Globals.lina_skill_inventory[lina_skill_select_index].upgrade]
		Globals.lina_skill_inventory[lina_skill_select_index].upgrade += 1
		info_insight.text = "Insight: " +  str(Globals.lina_skill_inventory[lina_skill_select_index].upgrade)  + "/" + str(Globals.lina_skill_inventory[lina_skill_select_index].steps.size())
		info_power.text = "Power: " + str(Globals.lina_skill_inventory[lina_skill_select_index].value + Globals.lina_skill_inventory[lina_skill_select_index].upgrade)
		if Globals.lina_skill_inventory[lina_skill_select_index].upgrade < Globals.lina_skill_inventory[lina_skill_select_index].steps.size():
			info_upgrade.text = str(Globals.lina_points) + "/" + str(Globals.lina_skill_inventory[lina_skill_select_index].price[Globals.lina_skill_inventory[lina_skill_select_index].upgrade])
			if Globals.lina_points < Globals.lina_skill_inventory[lina_skill_select_index].price[Globals.lina_skill_inventory[lina_skill_select_index].upgrade]:
				info_upgrade.modulate = Color.RED
			else:
				info_upgrade.modulate = Color.WHITE
		else:
			info_upgrade.text = "MAX"
	elif lina_skill_select_index != -1 and lina_skill_select.has_focus() and Globals.lina_skill_inventory[lina_skill_select_index].upgrade < Globals.lina_skill_inventory[lina_skill_select_index].steps.size() and Globals.lina_skill_inventory[lina_skill_select_index].price[Globals.lina_skill_inventory[lina_skill_select_index].upgrade] > Globals.lina_points:
			$Audio/SpellIsNot.play()
func state_control():
	if currentLocation == locations.BASE:
		if Input.is_action_just_pressed("up"):
			anim.play("go to settings")
			await get_tree().create_timer(0.2).timeout
			anim2.play("fog_down")
			menu_woosh.play()
			settings_menu_select()
			currentLocation = locations.SETTINGS
		if Input.is_action_just_pressed("right"):
			anim.play("go to lina")
			lina_menu_select()
			info.visible = true
			currentLocation = locations.CHARACTERS_LINA
		if Input.is_action_just_pressed("left") and Globals.is_alisa_in_party:
			anim.play("go to alisa")
			alisa_menu_select()
			info.visible = true
			currentLocation = locations.CHARACTERS_ALISA
		if Input.is_action_just_pressed("down"):
			camera_bob_anim.play("go to saves")
			currentLocation = locations.SAVES
			save_menu_select()
			await camera_bob_anim.animation_finished
			camera_bob_anim.play("camera_bob_saves")
	
	if currentLocation == locations.CHARACTERS_ALISA:
		if Input.is_action_just_pressed("back"):
			anim.play_backwards("go to alisa ONLY BACKWARDS")
			alisa_menu_deselect()
			info.visible = false
			currentLocation = locations.BASE
	
	if currentLocation == locations.CHARACTERS_LINA:
		if Input.is_action_just_pressed("back"):
			anim.play_backwards("go to lina")
			lina_menu_deselect()
			info.visible = false
			currentLocation = locations.BASE
			
	if currentLocation == locations.SETTINGS:
		if Input.is_action_just_pressed("back"):
			anim.play_backwards("go to settings")
			await get_tree().create_timer(0.2).timeout
			menu_woosh.play()
			anim2.play_backwards("fog_down")
			settings_menu_deselect()
			currentLocation = locations.BASE
		
	if currentLocation == locations.SAVES:
		if Input.is_action_just_pressed("back"):
			camera_bob_anim.play_backwards("go to saves")
			currentLocation = locations.BASE
			save_menu_deselect()
			await camera_bob_anim.animation_finished
			camera_bob_anim.play("camera_bob")



func alisa_menu_select():
	info_clear()
	await get_tree().create_timer(0.7).timeout
	alisa_item_select.process_mode = Node.PROCESS_MODE_ALWAYS
	alisa_skill_select.process_mode = Node.PROCESS_MODE_ALWAYS
	alisa_skill_select_index = -1
	alisa_item_select_index = -1
	alisa_lists_select()

func alisa_menu_deselect():
	alisa_item_select.clear()
	alisa_skill_select.clear()
	remember_select()
	alisa_item_select.process_mode = Node.PROCESS_MODE_DISABLED
	alisa_skill_select.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.5).timeout
	info_clear()

func lina_menu_select():
	info_clear()
	await get_tree().create_timer(0.7).timeout
	lina_item_select.process_mode = Node.PROCESS_MODE_ALWAYS
	lina_skill_select.process_mode = Node.PROCESS_MODE_ALWAYS
	lina_skill_select_index = -1
	lina_item_select_index = -1
	lina_lists_select()

func lina_menu_deselect():
	lina_item_select.clear()
	lina_skill_select.clear()
	remember_select()
	lina_item_select.process_mode = Node.PROCESS_MODE_DISABLED
	lina_skill_select.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.5).timeout
	info_clear()

func settings_menu_select():
	await get_tree().create_timer(0.5).timeout
	music_slider.process_mode = Node.PROCESS_MODE_ALWAYS
	sfx_slider.process_mode = Node.PROCESS_MODE_ALWAYS
	music_slider.grab_focus()

func settings_menu_deselect():
	music_slider.process_mode = Node.PROCESS_MODE_DISABLED
	sfx_slider.process_mode = Node.PROCESS_MODE_DISABLED

func save_menu_select():
	await get_tree().create_timer(0.5).timeout
	$SaveMenu/SaveButton.process_mode = Node.PROCESS_MODE_ALWAYS
	$SaveMenu/LoadButton.process_mode = Node.PROCESS_MODE_ALWAYS
	$SaveMenu/SaveButton.grab_focus()

func save_menu_deselect():
	$SaveMenu/SaveButton.process_mode = Node.PROCESS_MODE_DISABLED
	$SaveMenu/LoadButton.process_mode = Node.PROCESS_MODE_DISABLED



func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		music_bus_index,
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



func info_control(title, rus_title, desc, desc_ru, icon, level, power, steps, price, hp, atk, def, spd):
	match Globals.language:
		"ENG":info_title.text = title
		"RUS":info_title.text = rus_title
	match Globals.language:
		"ENG":info_desc.text = desc
		"RUS":info_desc.text = desc_ru
	info_icon.texture = icon
	
	if level != null:
		$CharacterMenu/Info/ChangingKey.visible = true
		$CharacterMenu/Info/ProgressBar.visible = true
		$CharacterMenu/Info/UpgradeLabel.visible = true
		match Globals.language:
			"ENG":info_insight.text = "Insight: " + str(level) + "/" + str(steps.size())
			"RUS":info_insight.text = "Понимание: " + str(level) + "/" + str(steps.size())
		match Globals.language:
			"ENG":info_power.text = "Power: " + str(power + sum_value(power, level, steps)) 
			"RUS":info_power.text = "Сила: " + str(power + sum_value(power, level, steps)) 
		if level < steps.size():
			if currentLocation == locations.CHARACTERS_ALISA:
				info_upgrade.text = str(Globals.alisa_points) + "/" + str(price[level])
				if Globals.alisa_points < price[level]:
					info_upgrade.modulate = Color.RED
				else:
					info_upgrade.modulate = Color.WHITE
			elif currentLocation == locations.CHARACTERS_LINA:
				info_upgrade.text = str(Globals.lina_points) + "/" + str(price[level])
				if Globals.lina_points < price[level]:
					info_upgrade.modulate = Color.RED
				else:
					info_upgrade.modulate = Color.WHITE
			else:
				info_upgrade.text = "MAX"
	else:
		$CharacterMenu/Info/ChangingKey.visible = false
		$CharacterMenu/Info/ProgressBar.visible = false 
		$CharacterMenu/Info/UpgradeLabel.visible = false 
		info_upgrade.text = ""
		info_power.text = ""
		info_insight.text = ""
	
	if hp != 0 and atk != 0 and def != 0 and spd != 0:
		alisa_hp.text = "HP: " + str(Globals.alisa_base_hp + hp)
		info_color(alisa_hp, Globals.alisa_hp, Globals.alisa_base_hp + hp)
		alisa_atk.text = "ATK: " + str(Globals.alisa_base_atk + atk)
		info_color(alisa_atk, Globals.alisa_atk, Globals.alisa_base_atk + atk)
		alisa_def.text = "DEF: " + str(Globals.alisa_base_def + def)
		info_color(alisa_def, Globals.alisa_def, Globals.alisa_base_def + def)
		alisa_spd.text = "SPD: " + str(Globals.alisa_base_spd + spd)
		info_color(alisa_spd, Globals.alisa_spd, Globals.alisa_base_spd + spd)
		
		lina_hp.text = "HP: " + str(Globals.lina_base_hp + hp)
		info_color(lina_hp, Globals.lina_hp, Globals.lina_base_hp + hp)
		lina_atk.text = "ATK: " + str(Globals.lina_base_atk + atk)
		info_color(lina_atk, Globals.lina_atk, Globals.lina_base_atk + atk)
		lina_def.text = "DEF: " + str(Globals.lina_base_def + def)
		info_color(lina_def, Globals.lina_def, Globals.lina_base_def + def)
		lina_spd.text = "SPD: " + str(Globals.lina_base_spd + spd)
		info_color(lina_spd, Globals.lina_spd, Globals.lina_base_spd + spd)
		
	else:
		alisa_hp.text = "HP: " + str(Globals.alisa_hp)
		alisa_atk.text = "ATK: " + str(Globals.alisa_atk)
		alisa_def.text = "DEF: " + str(Globals.alisa_def)
		alisa_spd.text = "SPD: " + str(Globals.alisa_spd)
	
		lina_hp.text = "HP: " + str(Globals.lina_hp)
		lina_atk.text = "ATK: " + str(Globals.lina_atk)
		lina_def.text = "DEF: " + str(Globals.lina_def)
		lina_spd.text = "SPD: " + str(Globals.lina_spd)


func sum_value(value, level, steps):
	var power = 0
	for i in level:
		power += steps[level]
	return power
	

func info_clear():
	
	info_title.text = ""
	info_desc.text = ""
	info_icon.texture = null
	$CharacterMenu/Info/ChangingKey.visible = false
	$CharacterMenu/Info/ProgressBar.visible = false 
	$CharacterMenu/Info/UpgradeLabel.visible = false 
	
	info_power.text = ""
	info_insight.text = ""
	info_upgrade.text = ""
	
	
	alisa_hp.text = "HP: " + str(Globals.alisa_hp)
	alisa_hp.modulate = "#ffffff"
	alisa_atk.text = "ATK: " + str(Globals.alisa_atk)
	alisa_atk.modulate = "#ffffff"
	alisa_def.text = "DEF: " + str(Globals.alisa_def)
	alisa_def.modulate = "#ffffff"
	alisa_spd.text = "SPD: " + str(Globals.alisa_spd)
	alisa_spd.modulate = "#ffffff"
	
	lina_hp.text = "HP: " + str(Globals.lina_hp)
	lina_hp.modulate = "#ffffff"
	lina_atk.text = "ATK: " + str(Globals.lina_atk)
	lina_atk.modulate = "#ffffff"
	lina_def.text = "DEF: " + str(Globals.lina_def)
	lina_def.modulate = "#ffffff"
	lina_spd.text = "SPD: " + str(Globals.lina_spd)
	lina_spd.modulate = "#ffffff"

func info_color(label, old_value, new_value):
	if old_value < new_value:
		label.modulate = "#47a942"
	if old_value == new_value:
		label.modulate = "#ffffff"
	if old_value > new_value:
		label.modulate = "#d12b2e"



func alisa_lists_select():
	
	alisa_item_select.clear()
	alisa_skill_select.clear()
	for i in Globals.inventory.size():
		match Globals.language:
			"ENG":alisa_item_select.add_item(Globals.inventory[i].title, Globals.inventory[i].icon, true)
			"RUS":alisa_item_select.add_item(Globals.inventory[i].rus_title, Globals.inventory[i].icon, true)
		if Globals.inventory[i] == Globals.alisa_equipped_item:
			alisa_item_select.select(i,false)
		if Globals.inventory[i] == Globals.lina_equipped_item:
			alisa_item_select.set_item_disabled(i,true)
	for i in Globals.alisa_skill_inventory.size():
		match Globals.language:
			"ENG":alisa_skill_select.add_item(Globals.alisa_skill_inventory[i].title, Globals.alisa_skill_inventory[i].icon, true)
			"RUS":alisa_skill_select.add_item(Globals.alisa_skill_inventory[i].rus_title, Globals.alisa_skill_inventory[i].icon, true)
		for j in Globals.alisa_equipped_skills.size():
			if i == Globals.alisa_equipped_skills[j]:
				alisa_skill_select.select(i,false)
		
	alisa_skill_select.grab_focus()

func _on_skill_select_gui_input(event: InputEvent) -> void:
	var item
	var max = Globals.alisa_skill_inventory.size()-1
	if (Input.is_action_just_pressed('down') or event.is_echo() and Input.is_action_pressed('down')) and alisa_skill_select_index < max and not Input.is_action_pressed('shift'):
		if not alisa_skill_select.is_item_disabled(alisa_skill_select_index+1):
			alisa_skill_select_index += 1
			item = Globals.alisa_skill_inventory[alisa_skill_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, item.upgrade, item.value, item.steps, item.price, 0, 0, 0, 0)
			change_sound.play()
			print(alisa_skill_select_index) 
		elif alisa_skill_select_index + 1 < max and not Input.is_action_pressed('shift'):
			alisa_skill_select_index += 2
			item = Globals.alisa_skill_inventory[alisa_skill_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, item.upgrade, item.value, item.steps, item.price, 0, 0, 0, 0)
			change_sound.play()
			print(alisa_skill_select_index) 
	if (Input.is_action_just_pressed('up') or event.is_echo() and Input.is_action_pressed('up')) and alisa_skill_select_index > 0 and not Input.is_action_pressed('shift'):
		if not alisa_skill_select.is_item_disabled(alisa_skill_select_index-1):
			alisa_skill_select_index -= 1
			item = Globals.alisa_skill_inventory[alisa_skill_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, item.upgrade, item.value, item.steps, item.price, 0, 0, 0, 0)
			change_sound.play()
			print(alisa_skill_select_index)
		elif alisa_skill_select_index - 1 > 0 and not Input.is_action_pressed('shift'):
			alisa_skill_select_index -= 2
			item = Globals.alisa_skill_inventory[alisa_skill_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, item.upgrade, item.value, item.steps, item.price, 0, 0, 0, 0)
			change_sound.play()
			print(alisa_skill_select_index)
	

func _on_item_select_gui_input(event: InputEvent) -> void:
	var item
	var max = Globals.inventory.size()-1
	if (Input.is_action_just_pressed('down') or event.is_echo() and Input.is_action_pressed('down')) and alisa_item_select_index < max and not Input.is_action_pressed('shift'):
		if not alisa_item_select.is_item_disabled(alisa_item_select_index+1):
			alisa_item_select_index += 1
			item = Globals.inventory[alisa_item_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, null, null, null, null, item.hp_value, item.atk_value, item.def_value, item.spd_value)
			change_sound.play()
		elif alisa_item_select_index + 1 < max and not Input.is_action_pressed('shift'):
			alisa_item_select_index += 2
			item = Globals.inventory[alisa_item_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, null, null, null, null, item.hp_value, item.atk_value, item.def_value, item.spd_value)
			change_sound.play()
		
	if (Input.is_action_just_pressed('up') or event.is_echo() and Input.is_action_pressed('up')) and alisa_item_select_index > 0 and not Input.is_action_pressed('shift'):
		if not alisa_item_select.is_item_disabled(alisa_item_select_index-1):
			alisa_item_select_index -= 1
			item = Globals.inventory[alisa_item_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, null, null, null, null, item.hp_value, item.atk_value, item.def_value, item.spd_value)
			change_sound.play()
		elif alisa_item_select_index - 1 > 0 and not Input.is_action_pressed('shift'):
			alisa_item_select_index -= 2
			item = Globals.inventory[alisa_item_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, null, null, null, null, item.hp_value, item.atk_value, item.def_value, item.spd_value)
			change_sound.play()
			
func _on_skill_select_focus_entered() -> void:
	var item
	var max = Globals.alisa_skill_inventory.size()-1
	item = Globals.alisa_skill_inventory[alisa_skill_select_index]
	if alisa_skill_select_index != -1:
		item = Globals.alisa_skill_inventory[alisa_skill_select_index]
		info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, item.upgrade, item.value, item.steps, item.price, 0, 0, 0, 0)

func _on_item_select_focus_entered() -> void:
	var item
	var max = Globals.inventory.size()-1
	item = Globals.inventory[alisa_item_select_index]
	if alisa_item_select_index != -1:
		item = Globals.inventory[alisa_item_select_index]
		info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, null, null, null, null, item.hp_value, item.atk_value, item.def_value, item.spd_value)



func lina_lists_select():
	lina_item_select.clear()
	lina_skill_select.clear()
	for i in Globals.inventory.size():
		match Globals.language:
			"ENG":lina_item_select.add_item(Globals.inventory[i].title, Globals.inventory[i].icon, true)
			"RUS":lina_item_select.add_item(Globals.inventory[i].rus_title, Globals.inventory[i].icon, true)
		if Globals.inventory[i] == Globals.lina_equipped_item:
			lina_item_select.select(i,false)
		if Globals.inventory[i] == Globals.alisa_equipped_item:
			lina_item_select.set_item_disabled(i,true)
	for i in Globals.lina_skill_inventory.size():
		match Globals.language:
			"ENG":lina_skill_select.add_item(Globals.lina_skill_inventory[i].title, Globals.lina_skill_inventory[i].icon, true)
			"RUS":lina_skill_select.add_item(Globals.lina_skill_inventory[i].rus_title, Globals.lina_skill_inventory[i].icon, true)
		for j in Globals.lina_equipped_skills.size():
			if i == Globals.lina_equipped_skills[j]:
				lina_skill_select.select(i,false)
		
	lina_skill_select.grab_focus()

func _on_skill_select_gui_input2(event: InputEvent) -> void:
	var item
	var max = Globals.lina_skill_inventory.size()-1
	
	if (Input.is_action_just_pressed('down') or event.is_echo() and Input.is_action_pressed('down')) and lina_skill_select_index < max and not Input.is_action_pressed('shift'):
		if not lina_skill_select.is_item_disabled(lina_skill_select_index+1):
			lina_skill_select_index += 1
			item = Globals.lina_skill_inventory[lina_skill_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, item.upgrade, item.value, item.steps, item.price, 0, 0, 0, 0)
			change_sound.play()
		elif lina_skill_select_index + 1 < max and not Input.is_action_pressed('shift'):
			lina_skill_select_index += 2
			item = Globals.lina_skill_inventory[lina_skill_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, item.upgrade, item.value, item.steps, item.price, 0, 0, 0, 0)
			change_sound.play()
			
	
	if (Input.is_action_just_pressed('up') or event.is_echo() and Input.is_action_pressed('up')) and lina_skill_select_index > 0 and not Input.is_action_pressed('shift'):
		if not lina_skill_select.is_item_disabled(lina_skill_select_index-1):
			lina_skill_select_index -= 1
			item = Globals.lina_skill_inventory[lina_skill_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, item.upgrade, item.value, item.steps, item.price, 0, 0, 0, 0)
			change_sound.play()
		elif lina_skill_select_index - 1 > 0 and not Input.is_action_pressed('shift'):
			lina_skill_select_index -= 2
			item = Globals.lina_skill_inventory[lina_skill_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, item.upgrade, item.value, item.steps, item.price, 0, 0, 0, 0)
			change_sound.play()

func _on_item_select_gui_input2(event: InputEvent) -> void:
	var item
	var max = Globals.inventory.size()-1
	if (Input.is_action_just_pressed('down') or event.is_echo() and Input.is_action_pressed('down')) and lina_item_select_index < max and not Input.is_action_pressed('shift'):
		if not lina_item_select.is_item_disabled(lina_item_select_index+1):
			lina_item_select_index += 1
			item = Globals.inventory[lina_item_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, null, null, null, null, item.hp_value, item.atk_value, item.def_value, item.spd_value)
			change_sound.play()
		elif lina_item_select_index + 1 < max and not Input.is_action_pressed('shift'):
			lina_item_select_index += 2
			item = Globals.inventory[lina_item_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, null, null, null, null, item.hp_value, item.atk_value, item.def_value, item.spd_value)
			change_sound.play()
			
	if (Input.is_action_just_pressed('up') or event.is_echo() and Input.is_action_pressed('up')) and lina_item_select_index > 0 and not Input.is_action_pressed('shift'):
		if not lina_item_select.is_item_disabled(lina_item_select_index-1):
			lina_item_select_index -= 1
			item = Globals.inventory[lina_item_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, null, null, null, null, item.hp_value, item.atk_value, item.def_value, item.spd_value)
			change_sound.play()
		elif lina_item_select_index - 1 > 0 and not Input.is_action_pressed('shift'):
			lina_item_select_index -= 2
			item = Globals.inventory[lina_item_select_index]
			info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, null, null, null, null, item.hp_value, item.atk_value, item.def_value, item.spd_value)
			change_sound.play()
			
func _on_skill_select_focus_entered2() -> void:
	var item
	var max = Globals.lina_skill_inventory.size()-1
	item = Globals.lina_skill_inventory[lina_skill_select_index]
	if lina_skill_select_index != -1:
		item = Globals.lina_skill_inventory[lina_skill_select_index]
		info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, item.upgrade, item.value, item.steps, item.price, 0, 0, 0, 0)

func _on_item_select_focus_entered2() -> void:
	var item
	var max = Globals.inventory.size()-1
	item = Globals.inventory[lina_item_select_index]
	if lina_item_select_index != -1:
		item = Globals.inventory[lina_item_select_index]
		info_control(item.title, item.rus_title, item.description, item.rus_description, item.icon, null, null, null, null, item.hp_value, item.atk_value, item.def_value, item.spd_value)


func select_change_check():
	if currentLocation == locations.CHARACTERS_ALISA:
		if 	alisa_skill_select.has_focus():
			if alisa_skill_selected_old != alisa_skill_select.get_selected_items():
				alisa_skill_select_changed.emit(alisa_skill_select_index)
			alisa_skill_selected_old = alisa_skill_select.get_selected_items()
		
		if 	alisa_item_select.has_focus():
			if alisa_item_selected_old != alisa_item_select.get_selected_items():
				alisa_item_select_changed.emit(alisa_item_select_index)
			alisa_item_selected_old = alisa_item_select.get_selected_items()
	
	if currentLocation == locations.CHARACTERS_LINA:
		if lina_skill_select.has_focus():
			if lina_skill_selected_old != lina_skill_select.get_selected_items():
				lina_skill_select_changed.emit(lina_skill_select_index)
			lina_skill_selected_old = lina_skill_select.get_selected_items()
		if lina_item_select.has_focus():
			if lina_item_selected_old != lina_item_select.get_selected_items():
				lina_item_select_changed.emit(lina_item_select_index)
			lina_item_selected_old = lina_item_select.get_selected_items()

func remember_select():
	alisa_skill_selected_old = alisa_skill_select.get_selected_items()
	alisa_item_selected_old = alisa_item_select.get_selected_items()
	lina_skill_selected_old = lina_skill_select.get_selected_items()
	lina_item_selected_old = lina_item_select.get_selected_items()


func _on_alisa_item_select_changed(index: Variant) -> void:
	if index != -1:
		select_sound.play()
		for i in Globals.inventory.size():
			if i != index:
				alisa_item_select.deselect(i)
		Globals.alisa_equipped_item = Globals.inventory[index]
		if alisa_item_select.get_selected_items().is_empty():
			alisa_item_select.select(index)

func _on_alisa_skill_select_changed(index: Variant) -> void:
	if index != -1:
		select_sound.play()
		Globals.alisa_equipped_skills.clear()
		if alisa_skill_select.get_selected_items().is_empty():
			alisa_skill_select.select(index)
		for i in alisa_skill_select.get_item_count():
			if alisa_skill_select.is_selected(i):
				Globals.alisa_equipped_skills.append(i)


func _on_lina_item_select_changed(index: Variant) -> void:
	if index != -1:
		select_sound.play()
		for i in Globals.inventory.size():
			if i != index:
				lina_item_select.deselect(i)
		Globals.lina_equipped_item = Globals.inventory[index]
		if lina_item_select.get_selected_items().is_empty():
			lina_item_select.select(index)
	
func _on_lina_skill_select_changed(index: Variant) -> void:
	if index != -1:
		select_sound.play()
		Globals.lina_equipped_skills.clear()
		if lina_skill_select.get_selected_items().is_empty():
			lina_skill_select.select(index)
		for i in lina_skill_select.get_item_count():
			if lina_skill_select.is_selected(i):
				Globals.lina_equipped_skills.append(i)


func _on_save_button_pressed() -> void:
	SaveAndLoad.save()


func _on_load_button_pressed() -> void:
	SaveAndLoad.save_load(false)
	save_menu_deselect()
	Soundtrack.unmute()
	menu_woosh.play()
	paused = false
	anim2.play_backwards("fog_left")
	await get_tree().create_timer(0.28).timeout
	$SubViewportContainer.visible = false
	$CharacterMenu.visible = false
	$Settings.visible = false
	$SaveMenu.visible = false
	$SubViewportContainer/SubViewport/DirectionalLight3D.visible = false
	get_tree().paused = false
	await get_tree().create_timer(0.22).timeout
	background_sound.stop()
	reset()
	
