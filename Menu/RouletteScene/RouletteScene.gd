extends Control

var is_spin = false
var degrees_collection = [0,45,90,135,180,225,270,315,360]
var random = RandomNumberGenerator.new() #Для генерации случайных чисел
var time_spin 
var purpose_degrees
var tween
var spin_available = true
var startDegrees
var available_spins = Global.available_spins
var coins = Global.coins
var end = false

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
func _on_storage_set_completed(success):
	print("On Storage Set Completed, success: ", success)
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			AudioServer.set_bus_mute(0,true)
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
			AudioServer.set_bus_mute(0,false)
func _on_rewarded_state_changed(state):
	if state == "opened":
		$AudioStreamPlayer.playing = false
		get_tree().paused = true
	elif state == "rewarded":
		available_spins += 1
		$available_spinsText.text = "Доступно прокрутов: " + str(available_spins)
		if Bridge.platform.language == "en":
			$available_spinsText.text = "Available spins: " + str(Global.available_spins)
		Bridge.storage.set(["spins","coins"], [available_spins,Global.coins], funcref(self, "_on_storage_set_completed"), Bridge.StorageType.LOCAL_STORAGE)
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
	Bridge.advertisement.connect("interstitial_state_changed", self, "_on_interstitial_state_changed")
	Bridge.advertisement.connect("rewarded_state_changed", self, "_on_rewarded_state_changed")
	Bridge.advertisement.show_interstitial()
	Bridge.storage.get(["spins", "coins"], funcref(self, "_on_storage_get_completed"), Bridge.StorageType.LOCAL_STORAGE) 
	$background.texture = load(Global.using_background)
	$background.position = Vector2(512,300)
	$background.scale = Vector2(0.8,0.833)
	if Bridge.platform.language == "en":
		$winText.text = "You win:"
		$Label.text = "+1 Spin"
		$roulette.texture = load("res://Assets/spinWheel2.png")
	random.randomize()
	tween = create_tween()
	$roulette.rotation_degrees = degrees_collection[0]
	startDegrees = $roulette.rotation_degrees
	$coinsText.text = "Монеты: " + str(Global.coins)
	if Bridge.platform.language == "en":
		$coinsText.text = "Coins: " + str(Global.coins)
	$available_spinsText.text = "Доступно прокрутов: " + str(Global.available_spins)
	if Bridge.platform.language == "en":
		$available_spinsText.text = "Available spins: " + str(Global.available_spins)
func create_tween():
	var t = Tween.new()
	add_child(t)
	return t
func exitBtn_pressed():
	Global.coins = coins
	Global.available_spins = available_spins
	Bridge.advertisement.show_interstitial() 
	get_tree().change_scene("res://Menu/Menu.tscn")
	Bridge.storage.set(["spins","coins"], [Global.available_spins,Global.coins], funcref(self, "_on_storage_set_completed"), Bridge.StorageType.LOCAL_STORAGE)
func spinBtn_pressed():
	if available_spins >= 1:
		is_spin = true

func _process(delta):
	var currentDegrees = fmod($roulette.rotation_degrees, 360)
	if is_spin == true && spin_available:
		available_spins -= 1
		spin_available = false
		time_spin = random.randi_range(8,14)
		purpose_degrees = degrees_collection[random.randi_range(1,8)]
		tween.interpolate_property($roulette,"rotation_degrees",startDegrees,purpose_degrees+10000,time_spin,Tween.TRANS_QUART,Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_completed")
		spin_available = true
		is_spin = false
		end = true
	if !is_spin && end:
		startDegrees = currentDegrees
		end = false
		if fmod($roulette.rotation_degrees, 360) >= 0 && fmod($roulette.rotation_degrees, 360) < 45:
			pass
		elif fmod($roulette.rotation_degrees, 360) >= 45 && fmod($roulette.rotation_degrees, 360) < 90:
			coins += 10
		elif fmod($roulette.rotation_degrees, 360) >= 90 && fmod($roulette.rotation_degrees, 360) < 135:
			pass
		elif fmod($roulette.rotation_degrees, 360) >= 135 && fmod($roulette.rotation_degrees, 360) < 180:
			coins += 1
		elif fmod($roulette.rotation_degrees, 360) >= 180 && fmod($roulette.rotation_degrees, 360) < 225:
			coins += 60
		elif fmod($roulette.rotation_degrees, 360) >= 225 && fmod($roulette.rotation_degrees, 360) < 270:
			coins += 5
		elif fmod($roulette.rotation_degrees, 360) >= 270 && fmod($roulette.rotation_degrees, 360) < 315:
			pass
		else:
			available_spins += 3
		$available_spinsText.text = "Доступно прокрутов: " + str(available_spins)
		$coinsText.text = "Монеты: " + str(coins)
		if Bridge.platform.language == "en":
			$available_spinsText.text = "Available spins: " + str(available_spins)
			$coinsText.text = "Coins: " + str(coins)
		Global.coins = coins
		Global.available_spins = available_spins
		Bridge.storage.set(["spins","coins"], [Global.available_spins,Global.coins], funcref(self, "_on_storage_set_completed"), Bridge.StorageType.LOCAL_STORAGE)
	if is_spin:
		if currentDegrees >= 0 && currentDegrees < 45:
			$winText.text = "Вы выиграли:\nНичего"
			if Bridge.platform.language == "en":
				$winText.text = "You win:\nNothing"
		elif currentDegrees >= 45 && currentDegrees < 90:
			$winText.text = "Вы выиграли:\n10 Монет"
			if Bridge.platform.language == "en":
				$winText.text = "You win:\n10 Coins"
		elif currentDegrees >= 90 && currentDegrees < 135:
			$winText.text = "Вы выиграли:\nНичего"
			if Bridge.platform.language == "en":
				$winText.text = "You win:\nNothing"
		elif currentDegrees >= 135 && currentDegrees < 180:
			$winText.text = "Вы выиграли:\n1 Монета"
			if Bridge.platform.language == "en":
				$winText.text = "You win:\n1 Coin"
		elif currentDegrees >= 180 && currentDegrees < 225:
			$winText.text = "Вы выиграли:\n60 Монет"
			if Bridge.platform.language == "en":
				$winText.text = "You win:\n60 Coins"
		elif currentDegrees >= 225 && currentDegrees < 270:
			$winText.text = "Вы выиграли:\n5 Монет "
			if Bridge.platform.language == "en":
				$winText.text = "You win:\n5 Coins"
		elif currentDegrees >= 270 && currentDegrees < 315:
			$winText.text = "Вы выиграли:\nНичего"
			if Bridge.platform.language == "en":
				$winText.text = "You win:\nNothing"
		else:
			$winText.text = "Вы выиграли:\n3 Бесплатных\nпрокрута"
			if Bridge.platform.language == "en":
				$winText.text = "You win:\n3 Spins"


func addSpin_pressed():
	Bridge.advertisement.show_rewarded()
