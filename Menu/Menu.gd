extends Control

func _on_storage_get_completed(success, data):
	if success:
		if data[0] != null:
			print("spins:", data[0])
			Global.available_spins = data[0]
		else:
			# Данных по ключу level нет
			print("Spins is null")
			
		if data[1] != null:
			print("Coins: ", data[1])
			Global.coins = data[1]
		else:
			# Данных по ключу coins нет
			print("Coins is null")
			
		if data[2] != null:
			Global.using_level = data[2]
		else:
			# Данных по ключу coins нет
			print("using level is null")
			
		if data[3] != null:
			Global.using_background = data[3]
		else:
			# Данных по ключу coins нет
			print("using background is null")
func _on_storage_set_completed(success):
	print("On Storage Set Completed, success: ", success)
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			AudioServer.set_bus_mute(0,true)
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
			AudioServer.set_bus_mute(0,false)
func _on_interstitial_state_changed(state):
	print(state)
	if state == "opened":
		$AudioStreamPlayer.playing = false
	elif state == "closed" || state == "failed":
		$AudioStreamPlayer.playing = true
func _ready():
	Bridge.storage.get(["spins", "coins","using_level","using_background"], funcref(self, "_on_storage_get_completed"), Bridge.StorageType.LOCAL_STORAGE) 
	if Bridge.platform.language == "ru":
		$Sprites/TitleSpriteENG.visible = false
		$Sprites/TitleSpriteRU.visible = true
		$Buttons/playBtn/Label.text = "Играть"
		$Buttons/difficultBtn/Label.text = "Сложность"
		$Buttons/rouletteBtn/Label.text = "Рулетка"
		$Buttons/shopBtn/Label.text = "Магазин"
		$Buttons/levelBtn/Label.text = "Уровни"
		$Sprites/Label.text = "Сортировка плиток"
	elif Bridge.platform.language == "en":
		$Sprites/TitleSpriteENG.visible = true
		$Sprites/TitleSpriteRU.visible = false
		$Buttons/playBtn/Label.text = "Play"
		$Buttons/difficultBtn/Label.text = "Difficult"
		$Buttons/rouletteBtn/Label.text = "Roulette"
		$Buttons/shopBtn/Label.text = "Shop"
		$Buttons/levelBtn/Label.text = "Levels"
		$Sprites/Label.text = "Sorting Stacks"
	$ParallaxBackground/ParallaxLayer/Sprite.texture = load(Global.using_background)
	$ParallaxBackground/ParallaxLayer/Sprite.position = Vector2(512,304)
	$ParallaxBackground/ParallaxLayer/Sprite.scale = Vector2(0.8,0.833)
	Bridge.platform.send_message("game_ready")
	Bridge.advertisement.connect("interstitial_state_changed", self, "_on_interstitial_state_changed")
	Bridge.advertisement.show_interstitial()
	print(Global.backgrounds_available) 
	
func playBtn_pressed():
	get_tree().change_scene("res://Level/World.tscn")

func difficultBtn_pressed():
	Bridge.advertisement.show_interstitial() 
	if !Global.is_hardLevel:
		$Buttons/difficultBtn.normal = load("res://Assets/buttons/btnPng2.png")
		$Buttons/difficultBtn.pressed = load("res://Assets/buttons/btnPng2.png")
		Global.is_hardLevel = true
	else:
		$Buttons/difficultBtn.normal = load("res://Assets/buttons/btnPng.png")
		$Buttons/difficultBtn.pressed = load("res://Assets/buttons/btnPng.png")
		Global.is_hardLevel = false


func rouletteBtn_pressed():
	get_tree().change_scene("res://Menu/RouletteScene/RouletteScene.tscn")


func shopBtn_pressed():
	get_tree().change_scene("res://Menu/ShopScene/Shop.tscn")


func levelBtn_pressed():
	get_tree().change_scene("res://Menu/LevelsScene/LevelsScene.tscn")
