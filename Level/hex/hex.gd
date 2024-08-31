extends StaticBody

func cell_selection(camera, event, position, normal, shape_idx): #Возвращает индексы по которым находится выбранная ячейка
	var map_node = get_tree().root.get_node("World/map")
	for i in map_node.mapSize_Z:
		for j in map_node.mapSize_X:
			if map_node.hex_map[i * map_node.mapSize_X + j].name == self.name:
				map_node.currentCell_Z = i
				map_node.currentCell_X = j

func mov_cell_selection(camera, event, position, normal, shape_idx): #Возвращаем индекс выбранной стопки, которую можно переместить
	var map_node = get_tree().root.get_node("World/map")
	for i in 3:
		if map_node.hex_base_selection[i].name == self.name:
				map_node.currentCell_I = i
