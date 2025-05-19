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
@onready var item_icon = $ItemIcon
@onready var anim = $AnimationPlayer
@onready var anim2 = $AnimationPlayer2

@onready var test_enemy = preload("res://scenes/globals/fight_chars/test_fight_char.tres")
@onready var test_enemy_sprite = preload("res://resourses/sprites/enemies/trash_enemy.png")

@onready var dishes_enemy = preload("res://scenes/globals/fight_chars/dishes_fight_char.tres")
@onready var dishes_enemy_sprite = preload("res://resourses/sprites/enemies/enemy_dishes.png")

@onready var washing_machine_enemy = preload("res://scenes/globals/fight_chars/washing_machine_fight_char.tres")
@onready var washing_machine_enemy_sprite = preload("res://resourses/sprites/enemies/washing_machine_enemy.png")

@onready var trash_enemy = preload("res://scenes/globals/fight_chars/trash_fight_char.tres")
@onready var trash_enemy_sprite = preload("res://resourses/sprites/enemies/trash_enemy.png")

@onready var inventory = preload("res://scenes/globals/items/inventory.tres")



@onready var last_beer = preload("res://scenes/globals/items/last_beer.tres")


enum p
{
	left, right
}
signal confirm_pressed
signal skip_pressed
signal dialogue_started
signal text_finished
signal battle_over

func _ready():
	BattleScene.battle_over.connect(_on_battle_over_export)

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
	
func easy_start(text: String):
	await get_tree().create_timer(0.05).timeout
	visible = true
	is_dialogue_active = true
	dialogue_started.emit()
	new_dialogue_window("", text, "", p.left)
	await text_finished
	await confirm_pressed
	finish()



func finish():
	await get_tree().create_timer(0.05).timeout
	left_portrait.visible = false
	right_portrait.visible = false
	visible = false
	is_dialogue_active = false
	text_label.text = ""
	name_label.text = ""
	name_box.visible = false
	text_box.visible = false
	
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
	name_box.visible = true
	name_label.text = name
	
func write_text(text:String):
	text_box.visible = true
	await get_tree().create_timer(0.05).timeout
	text_speed = base_text_speed
	text_label.text = text
	text_label.visible_characters = 0
	for i in text_label.get_total_character_count():
		text_label.visible_characters += 1
		if text[i] == ".":
			await get_tree().create_timer(0.15).timeout
		await get_tree().create_timer(text_speed).timeout
		if not $Audio/DialogueSound.playing:
			$Audio/DialogueSound.pitch_scale = randf_range(0.9,1.2)
			$Audio/DialogueSound.play()
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
		anim.play("fade_dark_both")

func give_item(text, item):
	name_box.visible = false
	item_icon.visible = true
	item_icon.texture = item.icon
	anim2.play("new item")
	inventory.items.append(item)
	write_text(text)
	show_portrait(null, p.right)

func start_fight(enemy, enemy_sprite, location, variant):
	visible = false
	is_dialogue_active = true
	Transition.play_battle_trans()
	Soundtrack.stop(location)
	BattleScene.start(enemy, enemy_sprite)

func end_fight():
	visible = true
	is_dialogue_active = true

func _on_battle_over_export():
	battle_over.emit()


#apartament
func starting_dialogue():
	InteractionMemory.starting_dialogue_used = true
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	new_dialogue_window("Lina","Aghhh.","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Why is the legal age for drinking is the same when your head starts to hurt in the morning...","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","AGHHHH!! DISHES!!","LinaAngry",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Maybe if I wait long enough Alice will wake up and do them for me.","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	player_sprite.frame = 9
	new_dialogue_window("Lina","Ptss.. Wake up...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","...", "" ,p.left)
	await text_finished
	await confirm_pressed
	player_sprite.frame = 0
	new_dialogue_window("Lina","...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","She's a guest after all.. Maybe I shoud be less lazy...","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	
	
	finish()


func dishes_dialogue():
	InteractionMemory.dishes_dialogue_used = true
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	new_dialogue_window("Lina","No...","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Why is this happening...","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Maybe it's about time I start using paper plates and forever forget about doing dishes.","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Okay.. Here we go...","LinaAngry",p.right)
	await text_finished
	await confirm_pressed
	start_fight(dishes_enemy, dishes_enemy_sprite, "apartament", 1)
	await battle_over
	end_fight()
	Soundtrack.play("apartament", 1)
	var dishes = get_tree().get_root().find_child("ChangingDishes",true,false)
	if BattleScene.slow_points > BattleScene.fast_points:
		dishes.change_state(2)
		InteractionMemory.dishes_state = 2
		dishes_dialogue_ending1()
	else: 
		dishes.change_state(3)
		InteractionMemory.dishes_state = 3
		dishes_dialogue_ending2()

func dishes_dialogue_ending1():
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	var alisa = get_tree().get_root().find_child("AlisaNPC",true,false)
	var alisa_sprite = alisa.find_child("Sprite3D",true,false)
	alisa.position = Vector3(0.222, 0.117, 0.065)
	alisa_sprite.frame = 3
	new_dialogue_window("Alice","Oh, what a pleasant surprise!","AlisaSmile",p.left)
	await text_finished
	await confirm_pressed
	alisa_sprite.frame = 6
	new_dialogue_window("Alice","You washed the dishes.","AlisaSmile",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","And here I thought it was my burden...","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	player_sprite.frame = 9
	new_dialogue_window("Lina","I would never make YOU do MY dishes.","LinaCocky",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Why would you even think that!?","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","What a good girl you are!","AlisaLaugh",p.left)
	await text_finished
	await confirm_pressed
	alisa_sprite.frame = 3
	new_dialogue_window("Alice","...","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","And you even did it properly this time!","AlisaSmile",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","I would even eat from these plates!","AlisaLaugh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","You're just squeamish.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	alisa_sprite.frame = 6
	new_dialogue_window("Alice","You know, maybe I should move in here.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","That would be gay.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","What's gay about this...","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","You know.. Living together.. Eating together... ","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Sleeping together...","LinaCocky",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","WHAT DO YOU MEAN SLEEPING TOGETHER!?","AlisaAngry",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Teehee.","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","I will never sleep with you.","AlisaAngry",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","I should reconsider moving in...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","It was a joke...","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Ahhh...","AlisaWow",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Anyway...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I still need your help.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I need to wash my clothes in washing machine and I dont know how to start the damn thing.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Are you banned on the internet?..","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","You burn your life away at the damn PC and cant even search up how to use a washing machine?..","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","...","LinaAngry",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Okay, I'll help...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","You shine brighter than sun, my beloved.","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","If you don't stop that lesbian shit I will bury you alive...","AlisaAngry",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Okay-okay.","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","But never insult my pooter like that again...","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Poo-what?..","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Pooter.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","...","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","You call your computer.. A POOTER??","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Yeah.. And???","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Thats the stupidest shit I've heard in my life...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	Transition.play_simple_transition()
	await get_tree().create_timer(0.5).timeout
	alisa.position.x = 100
	Globals.is_alisa_in_party = true
	var follow = get_tree().get_root().find_child("Follow",true,false)
	follow.position = Vector3(0.199, 0.117, 0.034)
	follow.activate()
	finish()

func dishes_dialogue_ending2():
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	var alisa = get_tree().get_root().find_child("AlisaNPC",true,false)
	var alisa_sprite = alisa.find_child("Sprite3D",true,false)
	alisa.position = Vector3(0.222, 0.117, 0.065)
	alisa_sprite.frame = 3
	new_dialogue_window("Alice","Oh, what a pleasant surprise!","AlisaSmile",p.left)
	await text_finished
	await confirm_pressed
	alisa_sprite.frame = 6
	new_dialogue_window("Alice","You washed the dishes.","AlisaSmile",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","And here I thought it was my burden...","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	player_sprite.frame = 9
	new_dialogue_window("Lina","I would never make YOU do MY dishes.","LinaCocky",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Why would you even think that!?","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","What a good girl you are!","AlisaLaugh",p.left)
	await text_finished
	await confirm_pressed
	alisa_sprite.frame = 3
	new_dialogue_window("Alice","...","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","And they are dirty..","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","I think I see a carrot slice...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","You're just squeamish.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	alisa_sprite.frame = 6
	new_dialogue_window("Alice","You know, you are too lazy sometimes.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Why do you say that...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Did you even see yourself?","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","When was the last time you washed yourself?","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Don't start, please...","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","And your hair.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Why do you only tie the back part of your hair?","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Thats comfortable!","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I dont like how hair feels on my neck.","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","And you.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","What's up with your neck-hiding hair collar?","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I bet it sweaty over there.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Yeah.. Maybe even a fungus.","LinaCocky",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","There's no fungus. I wash myself regularly unlike someone.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","That's a fungus talking I bet!","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","No way your hair is shaped like mushroom just because!","LinaCocky",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Stop it.","AlisaAngry",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Anyway.. About washing.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I still need your help.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I need to wash my clothes in washing machine and I dont know how to start the damn thing.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Are you banned on the internet?..","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","You burn your life away at the damn PC and cant even search up how to use a washing machine?..","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Okay, I'll help...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","You shine brighter than clean plates, bestie.","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","If you compare me to yours than defenetly.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","But never insult my pooter like that again...","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Poo-what?..","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Pooter.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","...","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","You call your computer.. A POOTER??","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Yeah.. And???","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Thats the stupidest shit I've heard in my life...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	Transition.play_simple_transition()
	await get_tree().create_timer(0.5).timeout
	alisa.position.x = 100
	Globals.is_alisa_in_party = true
	var follow = get_tree().get_root().find_child("Follow",true,false)
	follow.position = Vector3(0.199, 0.117, 0.034)
	follow.activate()
	finish()


func washing_machine_dialogue():
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	var alisa = get_tree().get_root().find_child("AlisaNPC",true,false)
	var alisa_sprite = alisa.find_child("Sprite3D",true,false)
	var follow = get_tree().get_root().find_child("Follow",true,false)
	Transition.play_simple_transition()
	await get_tree().create_timer(0.6).timeout
	alisa.position = Vector3(0, 0.119, 0.325)
	player.position = Vector3(0, 0.119, 0.208)
	follow.deactivate()
	player_sprite.frame = 6
	alisa_sprite.frame = 6
	new_dialogue_window("Alice","Aaand?..","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Theres like.. four buttons.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	player_sprite.frame = 0
	new_dialogue_window("Lina","Are you gonna help me or not?","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	alisa_sprite.frame = 3
	new_dialogue_window("Alice","...","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Hello?","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","I need to confess...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","I don't know how to use this thing either.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Whaaaaaa...","LinaWow",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","I live with my mom, what did you think?","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Guess I just imagined you know that stuff...","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	alisa_sprite.frame = 6
	new_dialogue_window("Alice","Problem still remains.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	player_sprite.frame = 6
	new_dialogue_window("Lina","Let's get over it...","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	start_fight(washing_machine_enemy, washing_machine_enemy_sprite, "apartament", 1)
	await battle_over
	end_fight()
	Soundtrack.play("apartament", 1)
	var clothes = get_tree().get_root().find_child("ChangingClothes",true,false)
	if BattleScene.slow_points > BattleScene.fast_points:
		clothes.change_state(2)
		InteractionMemory.clothes_state = 2
		washing_machine_dialogue_ending1()
	else: 
		clothes.change_state(3)
		InteractionMemory.clothes_state = 3
		washing_machine_dialogue_ending2()

func washing_machine_dialogue_ending1():
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	var alisa = get_tree().get_root().find_child("AlisaNPC",true,false)
	var alisa_sprite = alisa.find_child("Sprite3D",true,false)
	new_dialogue_window("Alice","Why it's so hard to use this.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","But we did it after all.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","By the way.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","When do you even use all this clothes?","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","You always wear the same thing when I see you.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","And what's the difference, I can wash my faivourite hoodie.","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","But we just washed your clothes.. And there wasn't your hoodie.","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","You don't even know how to use washing machine. How did you wash it before?..","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","...","LinaAngry",p.right)
	await text_finished
	await confirm_pressed
	if InteractionMemory.dishes_state == 2:
		new_dialogue_window("Alice","I think I was hasty when I said that you are a good girl...","AlisaSigh",p.left)
		await text_finished
		await confirm_pressed
	if InteractionMemory.dishes_state == 3:
		new_dialogue_window("Alice","And all the talk about fungus on my neck...","AlisaSigh",p.left)
		await text_finished
		await confirm_pressed
	new_dialogue_window("Alice","Stay away from me...","AlisaAngry",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","You finished?","LinaAngry",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I usually go to public washing where they do that stuff for me...","LinaAngry",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","And this is not even my clothes.","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","My mom insisted I learned how to wash clothes myself so she brought her own.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Oh.. I'm sorry...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","You're still half right.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	if InteractionMemory.dishes_state == 2:
		new_dialogue_window("Lina","I'm a filty girl.","LinaCocky",p.right)
		await text_finished
		await confirm_pressed
		new_dialogue_window("Lina","I will be as dirty as you want me to be, baby.","LinaCocky",p.right)
		await text_finished
		await confirm_pressed
		new_dialogue_window("Alice","Augh.. I'm gonna puke...","AlisaAngry",p.left)
		await text_finished
		await confirm_pressed
		new_dialogue_window("Lina","Okay, I'll stop now.","LinaSigh",p.right)
		await text_finished
		await confirm_pressed
	new_dialogue_window("Alice","...","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","What now?","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","One last thing.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","What now?..","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I trashed my room a little...","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	if InteractionMemory.alisa_saw_room:
		new_dialogue_window("Alice","Uh-huh.. A little.. I saw your room.","AlisaSigh",p.left)
		await text_finished
		await confirm_pressed
		new_dialogue_window("Lina","Yeah...","LinaSigh",p.right)
		await text_finished
		await confirm_pressed
	else:
		new_dialogue_window("Alice","A little? Then we will be done with it in no time.","AlisaSmile",p.left)
		await text_finished
		await confirm_pressed
		new_dialogue_window("Lina","Yeah...","LinaLaugh",p.right)
		await text_finished
		await confirm_pressed
	new_dialogue_window("Alice","Let's go then.","AlisaSmile",p.left)
	await text_finished
	await confirm_pressed
	Transition.play_simple_transition()
	await get_tree().create_timer(0.5).timeout
	alisa.position.x = 100
	var follow = get_tree().get_root().find_child("Follow",true,false)
	follow.position = Vector3(0, 0.119, 0.325)
	follow.activate()
	finish()
	
func washing_machine_dialogue_ending2():
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	var alisa = get_tree().get_root().find_child("AlisaNPC",true,false)
	var alisa_sprite = alisa.find_child("Sprite3D",true,false)
	new_dialogue_window("Alice","Say again...","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Why didn't we use the internet?","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Beacuse, internet is the worst source of inforamtion, of course.","LinaCocky",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Ooh, for some reason I recall that's not the reason.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","We thought we can manage with four buttons.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","You! Not WE!","AlisaAngry",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I did not stop you from searching it up.","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Okay, internet is the worst source of information.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","That's what I'm saying!","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	if InteractionMemory.dishes_state == 2:
		new_dialogue_window("Lina","You're entering toxic relationship with manipulitive girlfrind...","LinaCocky",p.right)
		await text_finished
		await confirm_pressed
		new_dialogue_window("Alice","I'm gonna skin you alive.","AlisaAngry",p.left)
		await text_finished
		await confirm_pressed
		new_dialogue_window("Lina","Okay, okay, I'll stop now.","LinaLaugh",p.right)
		await text_finished
		await confirm_pressed
	else:
		new_dialogue_window("Lina","At least I'm not the only one here...","LinaSigh",p.right)
		await text_finished
		await confirm_pressed
		new_dialogue_window("Alice","Don't compare us! I could wash dishes far better than you did.","AlisaAngry",p.left)
		await text_finished
		await confirm_pressed
	new_dialogue_window("Alice","You know, I'm the only one here who can say that about the internet.","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","At least I'm not chronically online.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","And why am I chronically online?","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","You send me videos and pictures like every 5 minutes.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","EVEN WHEN WE'RE NEXT TO EACH OTHER!","AlisaAngry",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","And they're hella funny!","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Maybe, but I'm busy most of the time and they distarct me.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","I even need to mute you sometime.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","You do WHAT?..","LinaWow",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","You're such a buzzkill...","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Forget it..","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","...","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","What now?","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","One last thing.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","What now?..","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I trashed my room a little...","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	if InteractionMemory.alisa_saw_room:
		new_dialogue_window("Alice","Uh-huh.. A little.. I saw your room.","AlisaSigh",p.left)
		await text_finished
		await confirm_pressed
		new_dialogue_window("Lina","Yeah...","LinaSigh",p.right)
		await text_finished
		await confirm_pressed
	else:
		new_dialogue_window("Alice","A little? Then we will be done with it in no time.","AlisaSmile",p.left)
		await text_finished
		await confirm_pressed
		new_dialogue_window("Lina","Yeah...","LinaLaugh",p.right)
		await text_finished
		await confirm_pressed
	new_dialogue_window("Alice","Let's go then.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	Transition.play_simple_transition()
	await get_tree().create_timer(0.5).timeout
	alisa.position.x = 100
	var follow = get_tree().get_root().find_child("Follow",true,false)
	follow.position = Vector3(0, 0.119, 0.325)
	follow.activate()
	finish()



func trash_dialogue():
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	var alisa = get_tree().get_root().find_child("AlisaNPC",true,false)
	var alisa_sprite = alisa.find_child("Sprite3D",true,false)
	var follow = get_tree().get_root().find_child("Follow",true,false)
	Transition.play_simple_transition()
	await get_tree().create_timer(0.6).timeout
	alisa.position = Vector3(-0.144, 0.119, 0.377)
	player.position = Vector3(0.056, 0.116, 0.377)
	follow.deactivate()
	player_sprite.frame = 3
	alisa_sprite.frame = 3
	new_dialogue_window("Alice","This is wild...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I had the time of my life, you know.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	alisa_sprite.frame = 9
	new_dialogue_window("Alice","And what was you doing?..","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	player_sprite.frame = 6
	new_dialogue_window("Lina","I hit my first FULL COMBO and PERFECT on EXTREME PLUS PLUS PLUS in Rythm Queen: Project Kekkai!!!","LinaWow",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","And it was only 6 HOURS!!!","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","You're insane...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","I wish I had all that time...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Enough complaining, start working, slave.","LinaCocky",p.right)
	await text_finished
	await confirm_pressed
	start_fight(trash_enemy, trash_enemy_sprite, "apartament", 1)
	await battle_over
	end_fight()
	Soundtrack.play("apartament", 1)
	var trash = get_tree().get_root().find_child("ChangingTrash",true,false)
	if BattleScene.slow_points > BattleScene.fast_points:
		trash.change_state(2)
		InteractionMemory.clothes_state = 2
		trash_dialogue_ending1()
	else: 
		trash.change_state(3)
		InteractionMemory.clothes_state = 3
		trash_dialogue_ending2()

func trash_dialogue_ending1():
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	var alisa = get_tree().get_root().find_child("AlisaNPC",true,false)
	var alisa_sprite = alisa.find_child("Sprite3D",true,false)
	new_dialogue_window("Alice","Not as bad as it seemed.","AlisaSmile",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","True, and all the work is over now.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","By the way.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Why do you even eat so much fast food.","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","It will make you fat.","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Firstly.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","No, it will not. I will never be fat.","LinaCocky",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Why is that?","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","That's just how I made. Sorry, not sorry.","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","It's unfair.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Secondly.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","What 'Secondly'?","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","You were asking about fast food?","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Ah, yeah. Continue.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","No, it was few seconds ago and you already forgot.","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Really think you should see a doctor...","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	if InteractionMemory.dishes_state == 2:
		new_dialogue_window("Lina","This fungus is really eating your brain...","LinaCocky",p.right)
		await text_finished
		await confirm_pressed
		new_dialogue_window("Alice","That's not funny...","AlisaAngry",p.left)
		await text_finished
		await confirm_pressed
		new_dialogue_window("Lina","I'm sorry...","LinaSigh",p.right)
		await text_finished
		await confirm_pressed
	new_dialogue_window("Lina","All this overworking is really getting you...","LinaSigh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","I just wanna move out faster.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Feels more like you're trying to save up you retirement savings...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","So, 'Secondly'.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","What 'Secondly'?","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","You're driving me crazy...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","FAST FOOD.","AlisaAngry",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Ah, yeah.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I can't get distracted.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Only in moments when I'm most focused I can do my best.","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","So I don't stop to cook while playing.","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	if InteractionMemory.dishes_state == 2:
		new_dialogue_window("Lina","Event the hair thing we talked about.","LinaSmile",p.right)
		await text_finished
		await confirm_pressed
	else:
		new_dialogue_window("Lina","I even tie my hair.","LinaSmile",p.right)
		await text_finished
		await confirm_pressed
	new_dialogue_window("Lina","I can get distracted from the smallest things.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Oh, your words have more sense than I expected.","AlisaWow",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","That's the second time I've seen you this talkative.","AlisaAngry",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I love to talk about things I love.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Okay.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Since we did everything that is needed, we can set off.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Where?","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","You forgot already?","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","I'll tell you on the way.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Let's go then.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	Transition.play_simple_transition()
	await get_tree().create_timer(0.5).timeout
	alisa.position.x = 100
	var follow = get_tree().get_root().find_child("Follow",true,false)
	follow.position = Vector3(0, 0.119, 0.325)
	follow.activate()
	finish()
	
func trash_dialogue_ending2():
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	var alisa = get_tree().get_root().find_child("AlisaNPC",true,false)
	var alisa_sprite = alisa.find_child("Sprite3D",true,false)
	new_dialogue_window("Alice","Not as bad as it seemed.","AlisaSmile",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","True, and all the work is over now.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","And why we left all these cans?..","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","You're joking?","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Look at the one on the bed.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","It's sleeping so peacefully.","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","It's a can of soda.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","And the great soda wall.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","How can you destroy such great building?","Linalaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","It's cans of soda stacked on each other...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","And a webcam?","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I have a literal soda webcam.","LinaLaugh",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Soda webcam...","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Why did you use 'literal'?..","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Is this some kind of pun?","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","No.","LinaCocky",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","...","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","So.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","We finished all the work?","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Yeah. Kind of.","LinaSmile",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Kind of?","AlisaQue",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Yeah. Kind of.","LinaCocky",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","So we have other work or not?","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","No.","LinaCocky",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","...","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","GET OUT OF MY HEAD!","AlisaAngry",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Wow, what's up?","LinaWow",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Stop trolling me. I don't understand like half of your jokes and it's driving me insane.","AlisaAngry",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Damn, you OK?","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","Yeah, sorry...","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","I'm worrying...","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","It's okay, really.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","We need to go.","AlisaDefault",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Where?","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","You forgot already?","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Alice","I'll tell you on the way.","AlisaSigh",p.left)
	await text_finished
	await confirm_pressed
	new_dialogue_window("Lina","Let's go then.","LinaDefault",p.right)
	await text_finished
	await confirm_pressed
	Transition.play_simple_transition()
	await get_tree().create_timer(0.5).timeout
	alisa.position.x = 100
	var follow = get_tree().get_root().find_child("Follow",true,false)
	follow.position = Vector3(0, 0.119, 0.325)
	follow.activate()
	finish()

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
	InteractionMemory.tv_used = true
	finish()

func fridge_interact():
	new_dialogue_window("","You think you might cry seeing this.","",p.left)
	await text_finished
	await confirm_pressed
	give_item("You recieve Last Beer.", last_beer)
	await anim2.animation_finished
	await confirm_pressed
	item_icon.visible = false
	InteractionMemory.fridge_used = true
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

func test_fight():
	start_fight(test_enemy, test_enemy_sprite, "apartament", 0)
	await battle_over
	Soundtrack.play("apartament", 0)
	finish()

func cant_leave_enter():
	var player = get_tree().get_root().find_child("Player",true,false)
	var player_sprite = player.find_child("Sprite3D",true,false)
	player_sprite.frame = 6
	new_dialogue_window("","You can't leave just now. You have things to do.","",p.left)
	await text_finished
	await confirm_pressed
	player.cutscene_walk(Vector2(1,0), "left", 0.2, 1)
	await player.cutscene_walk_ended
	finish()
