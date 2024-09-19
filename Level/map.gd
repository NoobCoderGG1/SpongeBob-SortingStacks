extends Spatial

var random = RandomNumberGenerator.new() #Для генерации случайных чисел
var HexStack = ResourceLoader.load("res://HexStack.gd") #Загрузка класса
var is_pressed = false #Состояние удержания(зажата ЛКМ)
var score = 0
var can_Move = true #Переменная для возможности поставить стопку
#Для генерации карты
var hex_size = 1.1
var hex_weight = hex_size * sqrt(3)
var hex_height = 2*hex_size - 0.5
var mapSize_X = random.randi_range(3,5)
var mapSize_Z = random.randi_range(3,5)
var max_score = 50 if !Global.is_hardLevel else 100

var hex_map = [] #Двумерный массив состоящий из самых нижних hex
var hex_stack_map = [] #Список стопок на карте класса HexStack
var hex_base_selection = [] #Список нижних hex'ов, на которых размещаются стопки для размещения
var hex_stack_selection = [] #Список стопок, которые нужно перетащить на карту для сортировки

var currentCell_Z; var currentCell_X #Индексы текущей ячейки
var currentCell_I #Индекс текущей ячейки выбора перемещаемой стопки

var old_base_hex; var new_base_hex #Для подсветки выбранного нижнего hex'a и возвращении прежнего цвета прошлому нижнему hex'у
var old_stack_hex; var new_stack_hex #Для подсветки выбранной стопки hex'ов и возвращении прежнего цвета прошлой стопке hex'ов
var old_sbase_hex; var new_sbase_hex #Для нижних hex'ов выбора
var old_sel_hex; var new_sel_hex #Для перемещаемых стопок
var startGame = false	
var endGame = false

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			AudioServer.set_bus_mute(0,true)
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
			AudioServer.set_bus_mute(0,false)
func _on_storage_set_completed(success):
	print("On Storage Set Completed, success: ", success)
func _on_interstitial_state_changed(state):
	print(state)
	if state == "opened":
		$"../GameAudio".playing = false
		$"../AddStackSound".playing = false
		$"../DelHexSound".playing = false
	elif state == "closed" || state == "failed":
		$"../GameAudio".playing = true
		$"../AddStackSound".playing = true
		$"../DelHexSound".playing = true
func _ready():
	Bridge.advertisement.connect("interstitial_state_changed", self, "_on_interstitial_state_changed")
	if Global.using_level == "spongeHouse":
		$"../UI/levelBackground".environment.background_sky.panorama = load("res://Assets/Backgrounds/spongebob-house-627x43myjnudtc21.jpg")
	elif Global.using_level == "sandyHouse":
		$"../UI/levelBackground".environment.background_sky.panorama = load("res://Assets/Backgrounds/Feral_Friends_203.png")
	elif Global.using_level == "krastyCrab":
		$"../UI/levelBackground".environment.background_sky.panorama = load("res://Assets/Backgrounds/1666723895_25-colodu-club-p-dom-mistera-krabsa-dizain-krasivo-26.png")
	elif Global.using_level == "bikiniBottom":
		$"../UI/levelBackground".environment.background_sky.panorama = load("res://Assets/Backgrounds/bikini-bottom_background.jpg")
	elif Global.using_level == "patrickHouse":
		$"../UI/levelBackground".environment.background_sky.panorama = load("res://Assets/Backgrounds/patrickHouse.png")
	$"../UI/Control".get_child(0).max_value = max_score
	random.randomize()
	generateMap()
	generateHexMap()
	generateHexSelection()
	old_base_hex = hex_map[0]
	old_stack_hex = hex_stack_map[0]
	old_sbase_hex = hex_base_selection[0]
	old_sel_hex = hex_stack_selection[0]
	currentCell_Z = mapSize_Z - 1
	currentCell_X = mapSize_X / 2
	currentCell_I = 0
	startGame = true
func _process(delta):
	paint_selectedCell() #Перекраска выбранной ячейки
	if score >= max_score && !endGame:
		endGame = true
		$"../UI/Control".get_child(0).visible = false
		$"../UI/Control".get_child(2).visible = true
		$"../UI/Control".get_child(1).position = Vector2(348,395)
		return
	#Тут вызов ready в случае чего
func _input(event):
	var is_drag = event is InputEventScreenDrag or event is InputEventMouseMotion
	var is_press = !is_drag and event.is_pressed()
	var is_release = !is_drag and !event.is_pressed()
	if (Input.is_action_just_pressed("mouse_left") || is_pressed) && startGame && Bridge.device.type != "mobile":
		is_pressed = true
		#var cursor_pos_x = get_viewport().get_mouse_position().x
		#var cursor_pos_y = get_viewport().get_mouse_position().y
		if hex_stack_selection[currentCell_I]:
			for l in hex_stack_selection[currentCell_I].stack_length:
				if currentCell_Z % 2 == 0:
					hex_stack_selection[currentCell_I].list[l].global_transform.origin = Vector3(currentCell_X * hex_weight, (0.7 + l * 1) * 0.5, currentCell_Z * hex_height)
				else:
					hex_stack_selection[currentCell_I].list[l].global_transform.origin = Vector3(currentCell_X * hex_weight + 1, (0.7 + l * 1) * 0.5, currentCell_Z * hex_height)
	if (is_drag||is_press) && startGame && Bridge.device.type == "mobile": #Для сенсорного ввода
		if hex_stack_selection[currentCell_I]:
			for l in hex_stack_selection[currentCell_I].stack_length:
				if currentCell_Z % 2 == 0:
					hex_stack_selection[currentCell_I].list[l].global_transform.origin = Vector3(currentCell_X * hex_weight, (0.7 + l * 1) * 0.5, currentCell_Z * hex_height)
				else:
					hex_stack_selection[currentCell_I].list[l].global_transform.origin = Vector3(currentCell_X * hex_weight + 1, (0.7 + l * 1) * 0.5, currentCell_Z * hex_height)
	
	if (Input.is_action_just_released("mouse_left") && startGame && Bridge.device.type != "mobile") || (is_release && startGame && Bridge.device.type == "mobile"):
		is_pressed = false
		if hex_stack_map[currentCell_Z*mapSize_X + currentCell_X] || !can_Move:
			if hex_stack_selection[currentCell_I]:
				for l in hex_stack_selection[currentCell_I].stack_length:
					if (mapSize_Z + mapSize_Z / 2) % 2 == 0:
						hex_stack_selection[currentCell_I].list[l].global_transform.origin = Vector3((currentCell_I + mapSize_X / 3) * hex_weight, (0.7 + l * 1) * 0.5, (mapSize_Z + mapSize_Z / 3) * hex_height)
					else:
						hex_stack_selection[currentCell_I].list[l].global_transform.origin = Vector3((currentCell_I + mapSize_X / 3) * hex_weight + 1, (0.7 + l * 1) * 0.5, (mapSize_Z + mapSize_Z / 3) * hex_height)
		else:
			if hex_stack_selection[currentCell_I]:
				hex_stack_map[currentCell_Z*mapSize_X + currentCell_X] = hex_stack_selection[currentCell_I]
				hex_stack_selection[currentCell_I] = 0
				$"../AddStackSound".play()
				sortingStacks() #После того как поставили стопку, производим их сортировку
				yield(get_tree().create_timer(6.0), "timeout")
				$"../AddStackSound".stop()
				#Генерация новых стопок, если все были потрачены
				for i in 3:
					if hex_stack_selection[i]:
						break
					if !hex_stack_selection[i] && i == 2:
						generateHexSelection()
		#Сделать проверку, что на выбранном месте нет стопок, иначе вернуть на место
		#Поставить стопку, еще в массив прописать hex_stack_map добавленную стопку, после чего удалить из списка по индексу currentCell_I поставив 0;
		
func generateMap():
	for z in mapSize_Z:
		for x in mapSize_X:
			var hex : StaticBody = preload("res://Level/hex/hex.tscn").instance()
			add_child(hex)
			if z % 2 == 0:
				hex.global_transform.origin = Vector3(x * hex_weight, 0, z * hex_height)
			else:
				hex.global_transform.origin = Vector3(x * hex_weight + 1, 0, z * hex_height)
			hex_map.append(hex) #Добавляем в массив
			hex_stack_map.append(0)
			var collision = CollisionShape.new() #Создаем коллизию для самых нижних hex'ов для взаимодействия с мышью
			collision.shape = CylinderShape.new()
			hex.add_child(collision)
			hex.connect("input_event",hex,"cell_selection") #Добавляем сигнал для взаимод. с мышью для нижних hex'ов
	for i in 3: #Генерация базовых hex'ов для стопок, которые нужно переместить
		var hex : StaticBody = preload("res://Level/hex/hex.tscn").instance()
		var collision = CollisionShape.new() #Создаем коллизию для самых нижних hex'ов для взаимодействия с мышью
		collision.shape = CylinderShape.new()
		hex.add_child(collision)
		add_child(hex)
		hex.connect("input_event",hex,"mov_cell_selection")
		if (mapSize_Z + mapSize_Z / 2) % 2 == 0:
			hex.global_transform.origin = Vector3((i + mapSize_X / 3) * hex_weight, 0, (mapSize_Z + mapSize_Z / 3) * hex_height)
		else:
			hex.global_transform.origin = Vector3((i + mapSize_X / 3) * hex_weight + 1, 0, (mapSize_Z + mapSize_Z / 3) * hex_height)
		hex_base_selection.append(hex)
		hex_stack_selection.append(0)
func generateHexMap(): #Генерация массива стопок и размещение самих стопок
	var countHex = random.randi_range(3,5) #Кол-во стопок на карте
	for c in countHex:
		var i = random.randi_range(0,mapSize_Z - 1)
		var j = random.randi_range(0,mapSize_X - 1)
		hex_stack_map[i*mapSize_X + j] = HexStack.HexStack.new(random.randi_range(2,7)) #Создание ссылки и присваивание ее ячейке массива;присваиваем высоту
		addStack(i,j,hex_stack_map[i*mapSize_X + j]) #Добавление стопки на нужное место
func generateHexSelection():
	for i in 3:
		hex_stack_selection[i] = HexStack.HexStack.new(random.randi_range(2,6))
		addStack(mapSize_Z + mapSize_Z / 2,i + mapSize_X / 3,hex_stack_selection[i])
func sortingStacks(): #Сортировка стопок
	var startCell_Z = 0 if currentCell_Z - 1 == -1 else currentCell_Z - 1  #Стартовый индекс Z с которого начнем проверку ячеек на присутствие стопок 
	var startCell_X = 0 if currentCell_X - 1 == -1 else currentCell_X - 1 #Стартовый индекс X с которого начнем проверку ячеек на присутствие стопок
	var n = 3 #Для пробежки по Z; 
	var k = 3 #Для пробежки по X;
	if currentCell_Z == 0 || currentCell_Z == mapSize_Z - 1: n = 2
	if currentCell_X == 0 || currentCell_X == mapSize_X - 1: k = 2
	var currentCell_Z2 = currentCell_Z
	var currentCell_X2 = currentCell_X
	for i in n:
		for j in k:
			#Поиск ближайших стопок, после нахождения добавляем на поставленную стопку ее плитки
			if hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)]:
				if hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)] != hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2]:
					var new_length = hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2].stack_length #Обновленная высота стопки поставленной
					var dec_count = 0 #На сколько высота уменьшилась у стопки, у которой отобрали плитки
					for l in hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].stack_length:
						if hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].list[hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].stack_length - l - 1].get_child(0).material_override.albedo_color != hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2].list[hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2].stack_length - 1].get_child(0).material_override.albedo_color:
							break
						if hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].list[hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].stack_length - l - 1].get_child(0).material_override.albedo_color == hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2].list[hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2].stack_length - 1].get_child(0).material_override.albedo_color:
							#Переносим плитку
							var vector = Vector3(currentCell_X2 * hex_weight, (0.7 + new_length * 1) * 0.5, currentCell_Z2 * hex_height) if currentCell_Z2 % 2 == 0 else Vector3(currentCell_X2 * hex_weight + 1, (0.7 + new_length * 1) * 0.5, currentCell_Z2 * hex_height)
							var tween = hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].list[hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].stack_length - l - 1].get_child(1)
							tween.interpolate_property(hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].list[hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].stack_length - l - 1],"translation",hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].list[hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].stack_length - l - 1].global_transform.origin
							,vector
							,1.0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT) #Заместо переменной vector в параметрах функции было - Vector3(hex_stack_map[currentCell_Z*mapSize_X + currentCell_X].list[hex_stack_map[currentCell_Z*mapSize_X + currentCell_X].stack_length - 1].global_transform.origin.x,(0.7 + new_length * 1) * 0.5,hex_stack_map[currentCell_Z*mapSize_X + currentCell_X].list[hex_stack_map[currentCell_Z*mapSize_X + currentCell_X].stack_length - 1].global_transform.origin.z)
							tween.start()
							new_length += 1
							dec_count += 1
							#Добавляем плитку в список поставленной и удаляем из списка откуда перенесли
							hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2].list.append(hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].list[hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].stack_length - l - 1])
							hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].list.erase(hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].list[hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].stack_length - l - 1])
					#Изменяем значения высоты стопок, если высота равна 0, то в массиве по этому месту выставляем 0
					hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2].stack_length = new_length
					hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].stack_length = hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].stack_length - dec_count
					if hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)].stack_length == 0:
						hex_stack_map[(startCell_Z+i)*mapSize_X + (startCell_X+j)] = 0
	#Проверка на высоту стопки, если она > 7, то удаляем стопки сверху-вниз пока цвет другой не встретим в списке
	if hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2].stack_length >= 7:
		can_Move = false
		var inspectorMaterial = hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2].list[hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2].stack_length - 1].get_child(0).material_override.albedo_color
		var dec_count = 0
		var hex_stack = hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2]
		for l in hex_stack.stack_length:
			var hex = hex_stack.list[hex_stack.stack_length - l - 1]
			if hex.get_child(0).material_override.albedo_color != inspectorMaterial:
				break
			dec_count += 1
			$"../DelHexSound".play()
			hex.get_child(0).material_override.params_blend_mode = SpatialMaterial.BLEND_MODE_ADD
			#var vector = Vector3(currentCell_X * hex_weight, (0.7 + new_length * 1) * 3, currentCell_Z * hex_height) if currentCell_Z % 2 == 0 else Vector3(currentCell_X * hex_weight + 1, (0.7 + new_length * 1) * 3, currentCell_Z * hex_height)
			var tween = hex_stack.list[hex_stack.stack_length - l - 1].get_child(1)
			tween.interpolate_property(hex_stack.list[hex_stack.stack_length - l - 1],"translation",hex_stack.list[hex_stack.stack_length - l - 1].global_transform.origin
			,Vector3(hex_stack.list[hex_stack.stack_length - l - 1].global_transform.origin.x,11,hex_stack.list[hex_stack.stack_length - l - 1].global_transform.origin.z)
			,1.0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			tween.start()
			yield(tween, "tween_completed")
			hex_stack.list.erase(hex)
			remove_child(hex)
		hex_stack.stack_length = hex_stack.stack_length - dec_count
		if hex_stack.stack_length == 0:
			hex_stack_map[currentCell_Z2*mapSize_X + currentCell_X2] = 0
		#И добавляем очки, и игра готова
		score += dec_count
		$"../UI/Control".get_child(0).value = score
		can_Move = true
		$"../DelHexSound".stop()
func paint_selectedCell(): #Перекраска выбранной ячейки
	#Вычислить элемент массива и поменять цвет нужной клетки
	new_base_hex = hex_map[currentCell_Z*mapSize_X+currentCell_X]
	new_stack_hex = hex_stack_map[currentCell_Z*mapSize_X+currentCell_X]
	new_sbase_hex = hex_base_selection[currentCell_I]
	new_sel_hex = hex_stack_selection[currentCell_I]
	if new_base_hex != old_base_hex:
		var newMaterial = SpatialMaterial.new() #Make a new Spatial Material
		newMaterial.albedo_color = Color(0.03, 0.88, 0.12, 1.0) #Set color of new material
		old_base_hex.get_child(0).material_override = newMaterial #Присваиваем материал hex-клетке
		old_base_hex = new_base_hex
		if old_stack_hex:
			for l in old_stack_hex.list.size():
				old_stack_hex.list[l].get_child(0).material_override.params_blend_mode = SpatialMaterial.BLEND_MODE_MIX
		old_stack_hex = new_stack_hex
	var newMaterial = SpatialMaterial.new() #Make a new Spatial Material
	newMaterial.albedo_color = Color(0.92, 0.69, 0.13, 1.0) #Set color of new material
	new_base_hex.get_child(0).material_override = newMaterial #Присваиваем материал hex-клетке
	if new_stack_hex:
		for l in new_stack_hex.list.size():
			new_stack_hex.list[l].get_child(0).material_override.params_blend_mode = SpatialMaterial.BLEND_MODE_ADD
	#Подсветка выбранной перемещаемой стопки
	if new_sbase_hex != old_sbase_hex:
		newMaterial = SpatialMaterial.new() #Make a new Spatial Material
		newMaterial.albedo_color = Color(0.03, 0.88, 0.12, 1.0) #Set color of new material
		old_sbase_hex.get_child(0).material_override = newMaterial #Присваиваем материал hex-клетке
		old_sbase_hex = new_sbase_hex
		if old_sel_hex:
			for l in old_sel_hex.list.size():
				old_sel_hex.list[l].get_child(0).material_override.params_blend_mode = SpatialMaterial.BLEND_MODE_MIX
		old_sel_hex = new_sel_hex
	newMaterial = SpatialMaterial.new() #Make a new Spatial Material
	newMaterial.albedo_color = Color(0.92, 0.69, 0.13, 1.0) #Set color of new material
	new_sbase_hex.get_child(0).material_override = newMaterial #Присваиваем материал hex-клетке
	if new_sel_hex:
		for l in new_sel_hex.stack_length:
			new_sel_hex.list[l].get_child(0).material_override.params_blend_mode = SpatialMaterial.BLEND_MODE_ADD
func addStack(z,x,hex_stack): #Добавление стопки на карту
	for l in hex_stack.stack_length:
		add_child(hex_stack.list[l]) #Добавление hex'а на сцену
		if z % 2 == 0:
			hex_stack.list[l].global_transform.origin = Vector3(x * hex_weight, (0.7 + l * 1) * 0.5, z * hex_height)
		else:
			hex_stack.list[l].global_transform.origin = Vector3(x * hex_weight + 1, (0.7 + l * 1) * 0.5, z * hex_height)
		#Добавить список этих стопок в hex_cout иначе не удалить, либо же создать еще один класс, который будет плитку представлять
		#а HexStack в списке будет хранить не материалы(цвета), а сами объекты плиток, для дальнейшего взаимодействия без необходимости
		#создания еще одного массива, который будет хранить все плитки уровня(кроме самых нижних) 
		
#Нужно сменить начало коорд с 0,0 до центра экрана допустим, чтобы потом можно быть по коорд мыши получить ячейку
# Берем коорд которые будут вместо 0,0 , затем (Текущие коорд - заданные) / размер ячейки = индекс массива
# Заданные начал.коорд:{500,300};Текущ коорд {551, 300};Размер ячейки50==> ({551,300} - {500,300}) / 50 = округляем(indx)
