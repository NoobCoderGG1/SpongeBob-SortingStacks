extends Node

class HexStack:
	var stack_length #Высота стопки из плиток
	var list = [] #Сами плитки (цвета)
	
	func _init(value):
		stack_length = value
		
		var random = RandomNumberGenerator.new() #Для генерации случайных чисел
		var countMaterial = random.randi_range(2,3) #Получение счетчика для плиток одного цвета
		var currentMaterial = generateMaterial() #Получение текущего цвета
		for y in stack_length: #Проходимся по высоте стопки
			if countMaterial == 0:
				countMaterial = random.randi_range(2,3)
				currentMaterial = generateMaterial()
			var hex : StaticBody = preload("res://Level/hex/hex.tscn").instance()
			hex.get_child(0).material_override = currentMaterial
			list.append(hex) #Добавление плитки в список
			countMaterial -= 1
			
	func generateMaterial(): #Получение рандомного материала(цвета плитки)
		var currentMaterial = SpatialMaterial.new()
		var rand = randi() % 5
		match rand:
			0,1:
				currentMaterial.albedo_color = Color(0.88, 0.03, 0.03, 1.0) #Красный
			2,3:
				currentMaterial.albedo_color = Color(0.02, 0.21, 0.96, 1.0) #Синий
			4,5:
				currentMaterial.albedo_color = Color(0.96, 0.88, 0.02, 1.0) #Желтый
		return currentMaterial
