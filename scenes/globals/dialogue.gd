extends CanvasLayer

var is_dialogue_active: bool = false
var base_text_speed = 0.03
var text_speed = 0.03

@onready var left_portrait = $Portraits/LeftPortarit
@onready var right_portrait = $Portraits/RightPortrait
@onready var name_label = $NameLabel
@onready var text_label = $TextLabel
@onready var name_box = $DialogueBoxSmall
@onready var text_box = $DialogueBoxBig
@onready var anim = $AnimationPlayer

enum p
{
	left, right
}
signal confirm_pressed
signal skip_pressed
signal dialogue_started
signal text_finished

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("confirm") and is_dialogue_active:
		confirm_pressed.emit()
		text_speed = 0.005
		
		

func start(name: String):
	await get_tree().create_timer(0.05).timeout
	visible = true
	is_dialogue_active = true
	var call_dialogue = Callable(self, name)
	dialogue_started.emit()
	call_dialogue.call()
	

	
func finish():
	await get_tree().create_timer(0.05).timeout
	left_portrait.visible = false
	right_portrait.visible = false
	visible = false
	is_dialogue_active = false
	text_label.text = ""
	name_label.text = ""
	
func new_dialogue_window(name, text, portrait, portrait_place):
	if name != "":
		name_box.visible = true
		write_name(name)
	else:
		name_box.visible = false
		write_name(name)
		
	write_text(text)
	
	if portrait != "":
		var portrait_sprite = get_tree().get_root().find_child(portrait,true,false)
		show_portrait(portrait_sprite, portrait_place)
	else:
		show_portrait(null, portrait_place)

func write_name(name:String):
	name_label.text = name
	
func write_text(text:String):
	await get_tree().create_timer(0.05).timeout
	text_speed = base_text_speed
	text_label.text = text
	text_label.visible_characters = 0
	for i in text_label.get_total_character_count():
		print(i,text_label.get_total_character_count())
		text_label.visible_characters += 1
		await get_tree().create_timer(text_speed).timeout
	text_speed = base_text_speed
	text_finished.emit()

func show_portrait(portrait, portrait_place):
	if portrait != null:
		if portrait_place == p.left:
			left_portrait.visible = true
			left_portrait.texture = portrait.texture
			anim.play_backwards("fade_dark_left")
			anim.play("fade_dark_right")
			anim.play("bounce_left_portrait")
			
		
		if portrait_place == p.right:
			right_portrait.visible = true
			right_portrait.texture = portrait.texture
			anim.play_backwards("fade_dark_right")
			anim.play("fade_dark_left")
			anim.play("bounce_right_portrait")
	else:
		anim.play("fade_dark_right")
		anim.play("fade_dark_left")
	


func tv_interact():
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	player_sprite.frame = 0
	new_dialogue_window("","Screen of the TV almost blinds you when you get close.","",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("","You slightly close your eyes and step away from it.","",p.left)
	await text_finished
	await confirm_pressed
	player.cutscene_walk(Vector2(0,-1), "down", 0.2, 1)
	await player.cutscene_walk_ended
	finish()

func alisa_apartament_interact():
	new_dialogue_window("Lina","Hey!! Wake up!!","LinaTest",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alisa","Hrrrr mimimimi..","AlisaTest",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("","Damn Shes sleeping..","",p.right)
	await text_finished
	await confirm_pressed
	finish()
