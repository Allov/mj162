extends Node

var items: Array[Item] = []

func spawn_item_by_name(item_name: String, position: Vector2) -> Item:
	var item = create_item_by_name(item_name)
	item.position = position
	add_child(item)
	items.append(item)
	
	return item	
	
func create_item_by_name(item_name: String):
	var item: PackedScene = load("res://world/item/" + item_name + ".tscn")
	return item.instantiate()

func find_nearest_item_by_type(item_type: Item.ItemType, pawn_position):
	var filtered_items = items.filter(func(item: Item): return item.type == item_type)

	if item_type == Item.ItemType.FOOD:
		filtered_items.sort_custom(func(a: Food, b: Food): return a.nutrition > b.nutrition)
		filtered_items = filtered_items.filter(func(food: Food): return food.nutrition >= filtered_items[0].nutrition)
		
	return _find_nearest_item(filtered_items, pawn_position)
	
func find_nearest_item_by_name(item_name: String, pawn_position):
	var filtered_items = items.filter(func(item: Item): return item.item_name.to_lower().begins_with(item_name))
	return _find_nearest_item(filtered_items, pawn_position)

func _find_nearest_item(filtered_items, pawn_position):
	var nearest_distance = 99999
	var nearest_item = null

	for item: Item in filtered_items:
		var distance = item.position.distance_to(pawn_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_item = item
			
	return nearest_item

func create_blue_print_by_name(item_name: String):
	var item: PackedScene = load("res://world/item/" + item_name + ".tscn")
	var created_item = item.instantiate()
	add_child(created_item)
	
	if created_item is Building:
		created_item.blue_print = true
		
	return created_item
	
func reserve_item(item):
	items.erase(item)
	
func remove_item(item):
	items.erase(item)
	item.queue_free()

