extends Control


var spongeBackground = false #Показывает имеется или нет
var menuBackground = false
var jellyBackground = false
var bikiniBackground = false

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
			print("Backgrounds available is true")
			var string_list = str(data[2])
			string_list[0] = ""
			string_list[string_list.length()-1] = ""
			Global.backgrounds_available = string_list.split(", ")
		else:
			
			print("Backgrounds available is null")
			
		if data[3] != null:
			print("Using Background is true")
			Global.using_background = data[3]
		else:
			print("using background is null")
			
func _on_storage_set_completed(success):
	print("On Storage Set Completed, success: ", success)
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			AudioServer.set_bus_mute(0,true)
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
			AudioServer.set_bus_mute(0,false)
# Called when the node enters the scene tree for the first time.
func _on_rewarded_state_changed(state):
	if state == "opened":
		$AudioStreamPlayer.playing = false
		get_tree().paused = true
	elif state == "rewarded":
		Global.coins += 30
		$coinText.text = "Монеты:\n " + str(Global.coins)
		if Bridge.platform.language == "en":
			$coinText.text = "Coins:\n " + str(Global.coins)
		Bridge.storage.set(["spins","coins"], [Global.available_spins,Global.coins], funcref(self, "_on_storage_set_completed"), Bridge.StorageType.LOCAL_STORAGE)
	elif state == "closed" || state == "failed":
		$AudioStreamPlayer.playing = true
		get_tree().paused = false
func _on_interstitial_state_changed(state):
	print(state)
	if state == "opened":
		$AudioStreamPlayer.playing = false
	elif state == "closed" || state == "failed":
		$AudioStreamPlayer.playing = true
func _ready():
	Bridge.storage.get(["spins", "coins","backgrounds_available","using_background"], funcref(self, "_on_storage_get_completed"), Bridge.StorageType.LOCAL_STORAGE)
	Bridge.advertisement.connect("interstitial_state_changed", self, "_on_interstitial_state_changed")
	Bridge.advertisement.connect("rewarded_state_changed", self, "_on_rewarded_state_changed")
	Bridge.advertisement.show_interstitial() 
	$background.texture = load(Global.using_background)
	$background.position = Vector2(512,300)
	$background.scale = Vector2(0.8,0.833)
	$coinText.text = "Монеты:\n " + str(Global.coins)
	if Bridge.platform.language == "en":
		$coinText.text = "Coins:\n " + str(Global.coins)
	for backgrounds in Global.backgrounds_available:
		if backgrounds == "spongeB":
			spongeBackground = true
			$buttons/Label4.text = "Использов"
		elif backgrounds == "menuB":
			menuBackground = true
			$buttons/Label.text = "Использов"
		elif backgrounds == "jellyB":
			jellyBackground = true
			$buttons/Label2.text = "Использов"
		elif backgrounds == "bikiniB":
			bikiniBackground = true
			$buttons/Label3.text = "Использов"
	if Bridge.platform.language == "en":
		$buttons/Label.text = "Buy"
		$buttons/Label2.text = "Buy"
		$buttons/Label3.text = "Buy"
		$buttons/Label4.text = "Buy"
		for backgrounds in Global.backgrounds_available:
			if backgrounds == "spongeB":
				$buttons/Label4.text = "Use"
			elif backgrounds == "menuB":
				$buttons/Label.text = "Use"
			elif backgrounds == "jellyB":
				$buttons/Label2.text = "Use"
			elif backgrounds == "bikiniB":
				$buttons/Label3.text = "Use"
		$Label.text = "Get 30 Coins"
	if Global.using_background == "res://Assets/Backgrounds/spongebob-house-627x43myjnudtc21.jpg":
		$buttons/Label4.text = "Использ."
		if Bridge.platform.language == "en":
			$buttons/Label4.text = "Using"
	elif Global.using_background == "res://Assets/Backgrounds/menu_background.jpg":
		$buttons/Label.text = "Использ."
		if Bridge.platform.language == "en":
			$buttons/Label.text = "Using"
	elif Global.using_background == "res://Assets/Backgrounds/jellyBackground.png":
		$buttons/Label2.text = "Использ."
		if Bridge.platform.language == "en":
			$buttons/Label2.text = "Using"
	elif Global.using_background == "res://Assets/Backgrounds/bikini-bottom_background.jpg":
		$buttons/Label3.text = "Использ."
		if Bridge.platform.language == "en":
			$buttons/Label3.text = "Using"
	print(Global.backgrounds_available) 
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func adBtn_pressed():
	Bridge.advertisement.show_rewarded()
	


func exitBtn_pressed():
	get_tree().change_scene("res://Menu/Menu.tscn")


func _on_stdBackBtn_pressed():
	if !menuBackground:
		if Global.coins >= 50:
			Global.coins -= 50
			$coinText.text = str(Global.coins)
			Global.backgrounds_available.append("menuB")
			menuBackground = true
			$buttons/Label.text = "Использовать"
			if Bridge.platform.language == "en":
				$buttons/Label.text = "Use"
	else:
		$buttons/Label.text = "Использ."
		if Bridge.platform.language == "en":
			$buttons/Label.text = "Using"
		Global.using_background = "res://Assets/Backgrounds/menu_background.jpg"
		$background.texture = load("res://Assets/Backgrounds/menu_background.jpg")
	Bridge.storage.set(["spins","coins","backgrounds_available","using_background"], [Global.available_spins,Global.coins,Global.backgrounds_available,Global.using_background], funcref(self, "_on_storage_set_completed"), Bridge.StorageType.LOCAL_STORAGE)
func _on_jellyBackBtn_pressed():
	if !jellyBackground:
		if Global.coins >= 100:
			Global.coins -= 100
			$coinText.text = str(Global.coins)
			Global.backgrounds_available.append("jellyB")
			jellyBackground = true
			$buttons/Label2.text = "Использовать"
			if Bridge.platform.language == "en":
				$buttons/Label2.text = "Use"
	else:
		$buttons/Label2.text = "Использ."
		if Bridge.platform.language == "en":
			$buttons/Label2.text = "Using"
		Global.using_background = "res://Assets/Backgrounds/jellyBackground.png"
		$background.texture = load("res://Assets/Backgrounds/jellyBackground.png")
	Bridge.storage.set(["spins","coins","backgrounds_available","using_background"], [Global.available_spins,Global.coins,Global.backgrounds_available,Global.using_background], funcref(self, "_on_storage_set_completed"), Bridge.StorageType.LOCAL_STORAGE)
	
func _on_BikinnyBackBtn_pressed():
	if !bikiniBackground:
		if Global.coins >= 200:
			Global.coins -= 200
			$coinText.text = str(Global.coins)
			Global.backgrounds_available.append("bikiniB")
			bikiniBackground = true
			$buttons/Label3.text = "Использовать"
			if Bridge.platform.language == "en":
				$buttons/Label3.text = "Use"
	else:
		$buttons/Label3.text = "Использ."
		if Bridge.platform.language == "en":
			$buttons/Label3.text = "Using"
		Global.using_background = "res://Assets/Backgrounds/bikini-bottom_background.jpg"
		$background.texture = load("res://Assets/Backgrounds/bikini-bottom_background.jpg")
	Bridge.storage.set(["spins","coins","backgrounds_available","using_background"], [Global.available_spins,Global.coins,Global.backgrounds_available,Global.using_background], funcref(self, "_on_storage_set_completed"), Bridge.StorageType.LOCAL_STORAGE)
	
func _on_spongeBackBtn_pressed():
	if !spongeBackground:
		if Global.coins >= 30:
			Global.coins -= 30
			$coinText.text = str(Global.coins)
			Global.backgrounds_available.append("spongeB")
			spongeBackground = true
			$buttons/Label4.text = "Использовать"
			if Bridge.platform.language == "en":
				$buttons/Label4.text = "Use"
	else:
		$buttons/Label4.text = "Использ."
		if Bridge.platform.language == "en":
			$buttons/Label4.text = "Using"
		Global.using_background = "res://Assets/Backgrounds/spongebob-house-627x43myjnudtc21.jpg"
		$background.texture = load("res://Assets/Backgrounds/spongebob-house-627x43myjnudtc21.jpg")
	Bridge.storage.set(["spins","coins","backgrounds_available","using_background"], [Global.available_spins,Global.coins,Global.backgrounds_available,Global.using_background], funcref(self, "_on_storage_set_completed"), Bridge.StorageType.LOCAL_STORAGE)
	print(Global.backgrounds_available) 
