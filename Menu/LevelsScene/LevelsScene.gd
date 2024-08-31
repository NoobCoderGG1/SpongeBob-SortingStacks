extends Control

var current_level_indx = 0
var levels = ["sandyHouse","krastyCrab","spongeHouse","bikiniBottom","patrickHouse"]
var sandy_lvl = false
var krasty_lvl = false
var sponge_lvl = false
var bikini_lvl = false
var patrick_lvl = false

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
			print("Levels available is true")
			var string_list = str(data[2])
			string_list[0] = ""
			string_list[string_list.length()-1] = ""
			Global.levels_available = string_list.split(", ")
		else:
			# Данных по ключу coins нет
			print("Levels available is null")
			
		if data[3] != null:
			Global.using_level = data[3]
		else:
			# Данных по ключу coins нет
			print("using level is null")
			
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
# Called when the node enters the scene tree for the first time.
func _ready():
	Bridge.storage.get(["spins", "coins","levels_available","using_level"], funcref(self, "_on_storage_get_completed"))
	Bridge.advertisement.connect("interstitial_state_changed", self, "_on_interstitial_state_changed")
	Bridge.advertisement.show_interstitial() 
	$background.texture = load(Global.using_background)
	$background.position = Vector2(512,300)
	$background.scale = Vector2(0.8,0.833)
	if Bridge.platform.language == "en":
		$Label2.text = "Buy"
	for level in Global.levels_available:
		if level == "sandyHouse":
			sandy_lvl = true
		elif level == "krastyCrab":
			krasty_lvl = true
		elif level == "spongeHouse":
			sponge_lvl = true
		elif level == "bikiniBottom":
			bikini_lvl = true
		elif level == "patrickHouse":
			patrick_lvl = true
	$coinText.text = "Монеты: " + str(Global.coins)
	if Bridge.platform.language == "en":
		$coinText.text = "Coins:" + str(Global.coins)
		$Label.text = "Levels"
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func exitBtn_pressed():
	get_tree().change_scene("res://Menu/Menu.tscn")


func leftBtn_pressed():
	if current_level_indx > 0:
		current_level_indx -=1
		if levels[current_level_indx] == "sandyHouse":
			$over.texture = load("res://Assets/levelsPictures/sandy_lvl/Over.png")
			$full.texture = load("res://Assets/levelsPictures/sandy_lvl/sandyHouseFull.png")
			$over.scale = Vector2(0.264,0.339)
			$over.position = Vector2(496,248)
			$full.scale = Vector2(0.264,0.339)
			$full.position = Vector2(496,248)
			$price.text = ""
			if sandy_lvl == false:
				$Label2.text = "Купить"
				if Bridge.platform.language == "en":
					$Label2.text = "Buy"
				$full.visible = false
				$price.text = "150"
			if sandy_lvl == true:
				$Label2.text = "Выбрать"
				if Bridge.platform.language == "en":
					$Label2.text = "Select"
				$full.visible = true
			if Global.using_level == "sandyHouse":
				$Label2.text = "Выбрано"
				if Bridge.platform.language == "en":
					$Label2.text = "Selected"
				$full.visible = true
		elif levels[current_level_indx] == "krastyCrab":
			$over.texture = load("res://Assets/levelsPictures/krasty_lvl/Over.png")
			$full.texture = load("res://Assets/levelsPictures/krasty_lvl/krastyCrabsFull.png")
			$over.scale = Vector2(0.303,0.379)
			$over.position = Vector2(496,264)
			$full.scale = Vector2(0.303,0.379)
			$full.position = Vector2(496,264)
			$price.text = ""
			if krasty_lvl == false:
				$Label2.text = "Купить"
				if Bridge.platform.language == "en":
					$Label2.text = "Buy"
				$full.visible = false
				$price.text = "250"
			if krasty_lvl == true:
				$Label2.text = "Выбрать"
				if Bridge.platform.language == "en":
					$Label2.text = "Select"
				$full.visible = true
			if Global.using_level == "krastyCrab":
				$Label2.text = "Выбрано"
				if Bridge.platform.language == "en":
					$Label2.text = "Selected"
				$full.visible = true
		elif levels[current_level_indx] == "spongeHouse":
			$over.texture = load("res://Assets/levelsPictures/sponge_lvl/Over.png")
			$full.texture = load("res://Assets/levelsPictures/sponge_lvl/SpongeFull.png")
			$over.scale = Vector2(0.326,0.21)
			$over.position = Vector2(504,256)
			$full.scale = Vector2(0.326,0.21)
			$full.position = Vector2(504,256)
			$price.text = ""
			if sponge_lvl == false:
				$Label2.text = "Купить"
				if Bridge.platform.language == "en":
					$Label2.text = "Buy"
				$full.visible = false
				$price.text = "350"
			if sponge_lvl == true:
				$Label2.text = "Выбрать"
				if Bridge.platform.language == "en":
					$Label2.text = "Select"
				$full.visible = true
			if Global.using_level == "spongeHouse":
				$Label2.text = "Выбрано"
				if Bridge.platform.language == "en":
					$Label2.text = "Selected"
				$full.visible = true
		elif levels[current_level_indx] == "bikiniBottom":
			$over.texture = load("res://Assets/levelsPictures/bikini_lvl/Over.png")
			$full.texture = load("res://Assets/levelsPictures/bikini_lvl/BikiniFull.png")
			$over.scale = Vector2(0.162,0.237)
			$over.position = Vector2(492,236)
			$full.scale = Vector2(0.162,0.237)
			$full.position = Vector2(492,236)
			$price.text = ""
			if bikini_lvl == false:
				$Label2.text = "Купить"
				if Bridge.platform.language == "en":
					$Label2.text = "Buy"
				$full.visible = false
				$price.text = "200"
			if bikini_lvl == true:
				$Label2.text = "Выбрать"
				if Bridge.platform.language == "en":
					$Label2.text = "Select"
				$full.visible = true
			if Global.using_level == "bikiniBottom":
				$Label2.text = "Выбрано"
				if Bridge.platform.language == "en":
					$Label2.text = "Selected"
				$full.visible = true
		elif levels[current_level_indx] == "patrickHouse":
			$over.texture = load("res://Assets/levelsPictures/patrick_lvl/Over.png")
			$full.texture = load("res://Assets/levelsPictures/patrick_lvl/PatrickFull.png")
			$over.scale = Vector2(0.303,0.379)
			$over.position = Vector2(496,264)
			$full.scale = Vector2(0.303,0.379)
			$full.position = Vector2(496,264)
			$price.text = ""
			if patrick_lvl == false:
				$Label2.text = "Купить"
				if Bridge.platform.language == "en":
					$Label2.text = "Buy"
				$full.visible = false
				$price.text = "150"
			if patrick_lvl == true:
				$Label2.text = "Выбрать"
				if Bridge.platform.language == "en":
					$Label2.text = "Select"
				$full.visible = true
			if Global.using_level == "patrickHouse":
				$Label2.text = "Выбрано"
				if Bridge.platform.language == "en":
					$Label2.text = "Selected"
				$full.visible = true
func rightBtn_pressed():
	if current_level_indx < 4:
		current_level_indx +=1
		if levels[current_level_indx] == "sandyHouse":
			$over.texture = load("res://Assets/levelsPictures/sandy_lvl/Over.png")
			$full.texture = load("res://Assets/levelsPictures/sandy_lvl/sandyHouseFull.png")
			$over.scale = Vector2(0.264,0.339)
			$over.position = Vector2(496,248)
			$full.scale = Vector2(0.264,0.339)
			$full.position = Vector2(496,248)
			$price.text = ""
			if sandy_lvl == false:
				$Label2.text = "Купить"
				if Bridge.platform.language == "en":
					$Label2.text = "Buy"
				$full.visible = false
				$price.text = "150"
			if sandy_lvl == true:
				$Label2.text = "Выбрать"
				if Bridge.platform.language == "en":
					$Label2.text = "Select"
				$full.visible = true
			if Global.using_level == "sandyHouse":
				$Label2.text = "Выбрано"
				if Bridge.platform.language == "en":
					$Label2.text = "Selected"
				$full.visible = true
		elif levels[current_level_indx] == "krastyCrab":
			$over.texture = load("res://Assets/levelsPictures/krasty_lvl/Over.png")
			$full.texture = load("res://Assets/levelsPictures/krasty_lvl/krastyCrabsFull.png")
			$over.scale = Vector2(0.303,0.379)
			$over.position = Vector2(496,264)
			$full.scale = Vector2(0.303,0.379)
			$full.position = Vector2(496,264)
			$price.text = ""
			if krasty_lvl == false:
				$Label2.text = "Купить"
				if Bridge.platform.language == "en":
					$Label2.text = "Buy"
				$full.visible = false
				$price.text = "250"
			if krasty_lvl == true:
				$Label2.text = "Выбрать"
				if Bridge.platform.language == "en":
					$Label2.text = "Select"
				$full.visible = true
			if Global.using_level == "krastyCrab":
				$Label2.text = "Выбрано"
				if Bridge.platform.language == "en":
					$Label2.text = "Selected"
				$full.visible = true
		elif levels[current_level_indx] == "spongeHouse":
			$over.texture = load("res://Assets/levelsPictures/sponge_lvl/Over.png")
			$full.texture = load("res://Assets/levelsPictures/sponge_lvl/SpongeFull.png")
			$over.scale = Vector2(0.326,0.21)
			$over.position = Vector2(504,256)
			$full.scale = Vector2(0.326,0.21)
			$full.position = Vector2(504,256)
			$price.text = ""
			if sponge_lvl == false:
				$Label2.text = "Купить"
				if Bridge.platform.language == "en":
					$Label2.text = "Buy"
				$full.visible = false
				$price.text = "350"
			if sponge_lvl == true:
				$Label2.text = "Выбрать"
				if Bridge.platform.language == "en":
					$Label2.text = "Select"
				$full.visible = true
			if Global.using_level == "spongeHouse":
				$Label2.text = "Выбрано"
				if Bridge.platform.language == "en":
					$Label2.text = "Selected"
				$full.visible = true
		elif levels[current_level_indx] == "bikiniBottom":
			$over.texture = load("res://Assets/levelsPictures/bikini_lvl/Over.png")
			$full.texture = load("res://Assets/levelsPictures/bikini_lvl/BikiniFull.png")
			$over.scale = Vector2(0.162,0.237)
			$over.position = Vector2(492,236)
			$full.scale = Vector2(0.162,0.237)
			$full.position = Vector2(492,236)
			$price.text = ""
			if bikini_lvl == false:
				$Label2.text = "Купить"
				if Bridge.platform.language == "en":
					$Label2.text = "Buy"
				$full.visible = false
				$price.text = "200"
			if bikini_lvl == true:
				$Label2.text = "Выбрать"
				if Bridge.platform.language == "en":
					$Label2.text = "Select"
				$full.visible = true
			if Global.using_level == "bikiniBottom":
				$Label2.text = "Выбрано"
				if Bridge.platform.language == "en":
					$Label2.text = "Selected"
				$full.visible = true
		elif levels[current_level_indx] == "patrickHouse":
			$over.texture = load("res://Assets/levelsPictures/patrick_lvl/Over.png")
			$full.texture = load("res://Assets/levelsPictures/patrick_lvl/PatrickFull.png")
			$over.scale = Vector2(0.303,0.379)
			$over.position = Vector2(496,264)
			$full.scale = Vector2(0.303,0.379)
			$full.position = Vector2(496,264)
			$price.text = ""
			if patrick_lvl == false:
				$Label2.text = "Купить"
				if Bridge.platform.language == "en":
					$Label2.text = "Buy"
				$full.visible = false
				$price.text = "150"
			if patrick_lvl == true:
				$Label2.text = "Выбрать"
				if Bridge.platform.language == "en":
					$Label2.text = "Select"
				$full.visible = true
			if Global.using_level == "patrickHouse":
				$Label2.text = "Выбрано"
				if Bridge.platform.language == "en":
					$Label2.text = "Selected"
				$full.visible = true

func selectBtn_pressed():
	if levels[current_level_indx] == "sandyHouse" && !sandy_lvl:
		if Global.coins >= 150:
			Global.coins -= 150
			Global.levels_available.append("sandyHouse")
			$Label2.text = "Выбрать"
			if Bridge.platform.language == "en":
				$Label2.text = "Select"
			sandy_lvl = true
			$price.text = ""
	elif levels[current_level_indx] == "sandyHouse" && sandy_lvl:
		$Label2.text = "Выбрано"
		if Bridge.platform.language == "en":
			$Label2.text = "Selected"
		Global.using_level = "sandyHouse"
		
	if levels[current_level_indx] == "krastyCrab" && !krasty_lvl:
		if Global.coins >= 250:
			Global.coins -= 250
			Global.levels_available.append("krastyCrab")
			$Label2.text = "Выбрать"
			if Bridge.platform.language == "en":
				$Label2.text = "Select"
			krasty_lvl = true
			$price.text = ""
	elif levels[current_level_indx] == "krastyCrab" && krasty_lvl:
		$Label2.text = "Выбрано"
		if Bridge.platform.language == "en":
			$Label2.text = "Selected"
		Global.using_level = "krastyCrab"
		
	if levels[current_level_indx] == "spongeHouse" && !sponge_lvl:
		if Global.coins >= 350:
			Global.coins -= 350
			Global.levels_available.append("spongeHouse")
			$Label2.text = "Выбрать"
			if Bridge.platform.language == "en":
				$Label2.text = "Select"
			sponge_lvl = true
			$price.text = ""
	elif levels[current_level_indx] == "spongeHouse" && sponge_lvl:
		$Label2.text = "Выбрано"
		if Bridge.platform.language == "en":
			$Label2.text = "Selected"
		Global.using_level = "spongeHouse"
		
	if levels[current_level_indx] == "bikiniBottom" && !bikini_lvl:
		if Global.coins >= 200:
			Global.coins -= 200
			Global.levels_available.append("bikiniBottom")
			$Label2.text = "Выбрать"
			if Bridge.platform.language == "en":
				$Label2.text = "Select"
			bikini_lvl = true
			$price.text = ""
	elif levels[current_level_indx] == "bikiniBottom" && bikini_lvl:
		$Label2.text = "Выбрано"
		if Bridge.platform.language == "en":
			$Label2.text = "Selected"
		Global.using_level = "bikiniBottom"
		
	if levels[current_level_indx] == "patrickHouse" && !patrick_lvl:
		if Global.coins >= 150:
			Global.coins -= 150
			Global.levels_available.append("patrickHouse")
			$Label2.text = "Выбрать"
			if Bridge.platform.language == "en":
				$Label2.text = "Select"
			patrick_lvl = true
			$price.text = ""
	elif levels[current_level_indx] == "patrickHouse" && patrick_lvl:
		$Label2.text = "Выбрано"
		if Bridge.platform.language == "en":
			$Label2.text = "Selected"
		Global.using_level = "patrickHouse"
	Bridge.storage.set(["spins","coins","levels_available","using_level"], [Global.available_spins,Global.coins,Global.levels_available,Global.using_level], funcref(self, "_on_storage_set_completed"))
	$coinText.text = "Монеты: " + str(Global.coins)
	if Bridge.platform.language == "en":
		$coinText.text = "Coins: " + str(Global.coins)
