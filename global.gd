extends Node

var is_hardLevel = false #Отвечает за сложность уровня
var coins : int = 20
var available_spins = 3
var backgrounds_available : Array = [] #Список всех имеющихся фонов (купленных)
var using_background = "res://backgroundSponge2.png"
var levels_available : Array = [] #Список всех имеющихся уровней (купленных)
var using_level = ""

