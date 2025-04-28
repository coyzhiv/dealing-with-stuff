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

@onready var anim = $AnimationPlayer
@onready var anim2 = $AnimationPlayer2

@onready var alisa_item_select = $CharacterMenu/Center/AlisaMenu/ItemSelect
@onready var alisa_skill_select = $CharacterMenu/Center/AlisaMenu/SkillSelect
@onready var alisa_menu = $CharacterMenu/Center/AlisaMenu
@onready var alisa_hp = $CharacterMenu/Center/AlisaMenu/HP
@onready var alisa_atk = $CharacterMenu/Center/AlisaMenu/ATK
@onready var alisa_def = $CharacterMenu/Center/AlisaMenu/DEF
@onready var alisa_spd = $CharacterMenu/Center/AlisaMenu/SPD

@onready var lina_item_select = $CharacterMenu/Center/LinaMenu/ItemSelect
@onready var lina_skill_select = $CharacterMenu/Center/LinaMenu/SkillSelect
@onready var lina_menu = $CharacterMenu/Center/LinaMenu
@onready var lina_hp = $CharacterMenu/Center/LinaMenu/HP
@onready var lina_atk = $CharacterMenu/Center/LinaMenu/ATK
@onready var lina_def = $CharacterMenu/Center/LinaMenu/DEF
@onready var lina_spd = $CharacterMenu/Center/LinaMenu/SPD


@onready var music_slider = $Settings/MusicSlider
@onready var sfx_slider = $Settings/SFXSlider

@onready var info = $CharacterMenu/Center/Info
@onready var info_title = $CharacterMenu/Center/Info/Title
@onready var info_desc = $CharacterMenu/Center/Info/Description
@onready var info_icon = $CharacterMenu/Center/Info/Icon


@onready var inventory = preload("res://scenes/globals/items/inventory.tres")
@onready var alisa_skill_inventory = preload("res://scenes/globals/skills/skill_inventory_alisa.tres")
@onready var lina_skill_inventory = preload("res://scenes/globals/skills/skill_inventory_lina.tres")



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
		select_change_check()
	
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
			info.visible = true
			currentLocation = locations.CHARACTERS_LINA
		if Input.is_action_just_pressed("back"):
			anim.play_backwards("go to characters")
			anim2.play("arrows blink")
			currentLocation = locations.BASE
		if Input.is_action_just_pressed("left"):
			anim.play("open alisa")
			alisa_menu_select()
			info.visible = true
			currentLocation = locations.CHARACTERS_ALISA
	
	if currentLocation == locations.CHARACTERS_ALISA:
		if Input.is_action_just_pressed("back"):
			anim.play_backwards("open alisa")
			alisa_menu_deselect()
			info.visible = false
			currentLocation = locations.CHARACTERS
	
	if currentLocation == locations.CHARACTERS_LINA:
		if Input.is_action_just_pressed("back"):
			anim.play_backwards("open lina")
			lina_menu_deselect()
			info.visible = false
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



func alisa_menu_select():
	await get_tree().create_timer(0.5).timeout
	alisa_menu.visible = true
	alisa_item_select.process_mode = Node.PROCESS_MODE_ALWAYS
	alisa_skill_select.process_mode = Node.PROCESS_MODE_ALWAYS
	alisa_skill_select_index = -1
	alisa_item_select_index = -1
	alisa_lists_select()

func alisa_menu_deselect():
	remember_select()
	alisa_menu.visible = false
	alisa_item_select.process_mode = Node.PROCESS_MODE_DISABLED
	alisa_skill_select.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.5).timeout
	info_clear()

func lina_menu_select():
	await get_tree().create_timer(0.5).timeout
	lina_menu.visible = true
	lina_item_select.process_mode = Node.PROCESS_MODE_ALWAYS
	lina_skill_select.process_mode = Node.PROCESS_MODE_ALWAYS
	lina_skill_select_index = -1
	lina_item_select_index = -1
	lina_lists_select()

func lina_menu_deselect():
	remember_select()
	lina_menu.visible = false
	lina_item_select.process_mode = Node.PROCESS_MODE_DISABLED
	lina_skill_select.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.5).timeout
	info_clear()

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



func info_control(title, desc, icon, hp, atk, def, spd):
	info_title.text = title
	info_desc.text = desc
	info_icon.texture = icon
	
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
		lina_atk.text = "ATK: " + str(Globals.lina_hp)
		lina_def.text = "DEF: " + str(Globals.lina_hp)
		lina_spd.text = "SPD: " + str(Globals.lina_hp)

func info_clear():
	info_title.text = ""
	info_desc.text = ""
	info_icon.texture = null
	
	alisa_hp.text = "HP: " + str(Globals.alisa_hp)
	alisa_atk.text = "ATK: " + str(Globals.alisa_atk)
	alisa_def.text = "DEF: " + str(Globals.alisa_def)
	alisa_spd.text = "SPD: " + str(Globals.alisa_spd)
	
	lina_hp.text = "HP: " + str(Globals.lina_hp)
	lina_atk.text = "ATK: " + str(Globals.lina_hp)
	lina_def.text = "DEF: " + str(Globals.lina_hp)
	lina_spd.text = "SPD: " + str(Globals.lina_hp)

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
	for i in inventory.items.size():
		alisa_item_select.add_item(inventory.items[i].title, inventory.items[i].icon, true)
		if inventory.items[i] == Globals.alisa_equipped_item:
			alisa_item_select.select(i,false)
		if inventory.items[i] == Globals.lina_equipped_item:
			alisa_item_select.set_item_disabled(i,true)
	for i in alisa_skill_inventory.items.size():
		alisa_skill_select.add_item(alisa_skill_inventory.items[i].title, alisa_skill_inventory.items[i].icon, true)
		if Globals.alisa_equipped_skills.items.has(alisa_skill_inventory.items[i]):
			alisa_skill_select.select(i,false)
		
	alisa_skill_select.grab_focus()

func _on_skill_select_gui_input(event: InputEvent) -> void:
	var item
	var max = alisa_skill_inventory.items.size()-1
	if Input.is_action_just_pressed('down') and alisa_skill_select_index < max:
		if not alisa_skill_select.is_item_disabled(alisa_skill_select_index+1):
			alisa_skill_select_index += 1
			item = alisa_skill_inventory.items[alisa_skill_select_index]
			info_control(item.title, item.description, item.icon, 0, 0, 0, 0)
		elif alisa_skill_select_index + 1 < max:
			alisa_skill_select_index += 2
			item = alisa_skill_inventory.items[alisa_skill_select_index]
			info_control(item.title, item.description, item.icon, 0, 0, 0, 0)
	if Input.is_action_just_pressed('up') and alisa_skill_select_index > 0:
		if not alisa_skill_select.is_item_disabled(alisa_skill_select_index-1):
			alisa_skill_select_index -= 1
			item = alisa_skill_inventory.items[alisa_skill_select_index]
			info_control(item.title, item.description, item.icon, 0, 0, 0, 0)
		elif alisa_skill_select_index - 1 > 0:
			alisa_skill_select_index -= 2
			item = alisa_skill_inventory.items[alisa_skill_select_index]
			info_control(item.title, item.description, item.icon, 0, 0, 0, 0)

func _on_item_select_gui_input(event: InputEvent) -> void:
	var item
	var max = inventory.items.size()-1
	if Input.is_action_just_pressed('down') and alisa_item_select_index < max:
		if not alisa_item_select.is_item_disabled(alisa_item_select_index+1):
			alisa_item_select_index += 1
			item = inventory.items[alisa_item_select_index]
			info_control(item.title, item.description, item.icon, item.hp_value, item.atk_value, item.def_value, item.spd_value)
		elif alisa_item_select_index + 1 < max:
			alisa_item_select_index += 2
			item = inventory.items[alisa_item_select_index]
			info_control(item.title, item.description, item.icon, item.hp_value, item.atk_value, item.def_value, item.spd_value)
			
		
	if Input.is_action_just_pressed('up') and alisa_item_select_index > 0:
		if not alisa_item_select.is_item_disabled(alisa_item_select_index-1):
			alisa_item_select_index -= 1
			item = inventory.items[alisa_item_select_index]
			info_control(item.title, item.description, item.icon, item.hp_value, item.atk_value, item.def_value, item.spd_value)
		elif alisa_item_select_index - 1 > 0:
			alisa_item_select_index -= 2
			item = inventory.items[alisa_item_select_index]
			info_control(item.title, item.description, item.icon, item.hp_value, item.atk_value, item.def_value, item.spd_value)

func _on_skill_select_focus_entered() -> void:
	var item
	var max = alisa_skill_inventory.items.size()-1
	item = alisa_skill_inventory.items[alisa_skill_select_index]
	if alisa_skill_select_index != -1:
		item = alisa_skill_inventory.items[alisa_skill_select_index]
		info_control(item.title, item.description, item.icon, 0, 0, 0, 0)

func _on_item_select_focus_entered() -> void:
	var item
	var max = inventory.items.size()-1
	item = inventory.items[alisa_item_select_index]
	if alisa_item_select_index != -1:
		item = inventory.items[alisa_item_select_index]
		info_control(item.title, item.description, item.icon, item.hp_value, item.atk_value, item.def_value, item.spd_value)



func lina_lists_select():
	lina_item_select.clear()
	lina_skill_select.clear()
	for i in inventory.items.size():
		lina_item_select.add_item(inventory.items[i].title, inventory.items[i].icon, true)
		if inventory.items[i] == Globals.lina_equipped_item:
			lina_item_select.select(i,false)
		if inventory.items[i] == Globals.alisa_equipped_item:
			lina_item_select.set_item_disabled(i,true)
	for i in lina_skill_inventory.items.size():
		lina_skill_select.add_item(lina_skill_inventory.items[i].title, lina_skill_inventory.items[i].icon, true)
		if Globals.lina_equipped_skills.items.has(lina_skill_inventory.items[i]):
			lina_skill_select.select(i,false)
		
	lina_skill_select.grab_focus()

func _on_skill_select_gui_input2(event: InputEvent) -> void:
	var item
	var max = lina_skill_inventory.items.size()-1
	if Input.is_action_just_pressed('down') and lina_skill_select_index < max:
		if not lina_skill_select.is_item_disabled(lina_skill_select_index+1):
			lina_skill_select_index += 1
			item = lina_skill_inventory.items[lina_skill_select_index]
			info_control(item.title, item.description, item.icon, 0, 0, 0, 0)
		elif lina_skill_select_index + 1 < max:
			lina_skill_select_index += 2
			item = lina_skill_inventory.items[lina_skill_select_index]
			info_control(item.title, item.description, item.icon, 0, 0, 0, 0)
			
	
	if Input.is_action_just_pressed('up') and lina_skill_select_index > 0:
		if not lina_skill_select.is_item_disabled(lina_skill_select_index-1):
			lina_skill_select_index -= 1
			item = lina_skill_inventory.items[lina_skill_select_index]
			info_control(item.title, item.description, item.icon, 0, 0, 0, 0)
		elif lina_skill_select_index - 1 > 0:
			lina_skill_select_index -= 2
			item = lina_skill_inventory.items[lina_skill_select_index]
			info_control(item.title, item.description, item.icon, 0, 0, 0, 0)

func _on_item_select_gui_input2(event: InputEvent) -> void:
	var item
	var max = inventory.items.size()-1
	if Input.is_action_just_pressed('down') and lina_item_select_index < max:
		if not lina_item_select.is_item_disabled(lina_item_select_index+1):
			lina_item_select_index += 1
			item = inventory.items[lina_item_select_index]
			info_control(item.title, item.description, item.icon, item.hp_value, item.atk_value, item.def_value, item.spd_value)
		elif lina_item_select_index + 1 < max:
			lina_item_select_index += 2
			item = inventory.items[lina_item_select_index]
			info_control(item.title, item.description, item.icon, item.hp_value, item.atk_value, item.def_value, item.spd_value)
	
	if Input.is_action_just_pressed('up') and lina_item_select_index > 0:
		if not lina_item_select.is_item_disabled(lina_item_select_index-1):
			lina_item_select_index -= 1
			item = inventory.items[lina_item_select_index]
			info_control(item.title, item.description, item.icon, item.hp_value, item.atk_value, item.def_value, item.spd_value)
		elif lina_item_select_index - 1 > 0:
			lina_item_select_index -= 2
			item = inventory.items[lina_item_select_index]
			info_control(item.title, item.description, item.icon, item.hp_value, item.atk_value, item.def_value, item.spd_value)

func _on_skill_select_focus_entered2() -> void:
	var item
	var max = lina_skill_inventory.items.size()-1
	item = lina_skill_inventory.items[lina_skill_select_index]
	if lina_skill_select_index != -1:
		item = lina_skill_inventory.items[lina_skill_select_index]
		info_control(item.title, item.description, item.icon, 0, 0, 0, 0)

func _on_item_select_focus_entered2() -> void:
	var item
	var max = inventory.items.size()-1
	item = inventory.items[lina_item_select_index]
	if lina_item_select_index != -1:
		item = inventory.items[lina_item_select_index]
		info_control(item.title, item.description, item.icon, item.hp_value, item.atk_value, item.def_value, item.spd_value)


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
		for i in inventory.items.size():
			if i != index:
				alisa_item_select.deselect(i)
		Globals.alisa_equipped_item = inventory.items[index]
		if alisa_item_select.get_selected_items().is_empty():
			alisa_item_select.select(index)

func _on_alisa_skill_select_changed(index: Variant) -> void:
	if index != -1:
		Globals.alisa_equipped_skills.items.clear()
		if alisa_skill_select.get_selected_items().is_empty():
			alisa_skill_select.select(index)
		for i in alisa_skill_select.get_selected_items().size():
			Globals.alisa_equipped_skills.items.append(alisa_skill_inventory.items[alisa_skill_select.get_selected_items()[i]])


func _on_lina_item_select_changed(index: Variant) -> void:
	if index != -1:
		for i in inventory.items.size():
			if i != index:
				lina_item_select.deselect(i)
		Globals.lina_equipped_item = inventory.items[index]
		if lina_item_select.get_selected_items().is_empty():
			lina_item_select.select(index)
	
func _on_lina_skill_select_changed(index: Variant) -> void:
	if index != -1:
		
		Globals.lina_equipped_skills.items.clear()
		if lina_skill_select.get_selected_items().is_empty():
			lina_skill_select.select(index)
		for i in lina_skill_select.get_selected_items().size():
			Globals.lina_equipped_skills.items.append(lina_skill_inventory.items[lina_skill_select.get_selected_items()[i]])
