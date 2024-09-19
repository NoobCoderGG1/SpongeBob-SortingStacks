extends Control

func _on_storage_set_completed(success):
	print("On Storage Set Completed, success: ", success)
func _ready():
	if Bridge.platform.language == "en":
		$endGame/Label.text = "You Completed Level!\nYou win: 35 Coins!"



func exitBtn_pressed():
	Global.coins += int(25)
	Bridge.storage.set(["spins","coins"], [Global.available_spins,Global.coins], funcref(self, "_on_storage_set_completed"))
	get_tree().change_scene("res://Menu/Menu.tscn")


func restartBtn_pressed():
	Global.coins += int(35)
	Bridge.storage.set(["spins","coins"], [Global.available_spins,Global.coins], funcref(self, "_on_storage_set_completed"))
	Bridge.advertisement.show_interstitial() 
	get_tree().change_scene("res://Level/World.tscn")
