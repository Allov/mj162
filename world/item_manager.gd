extends Node

var items = []

func spawn_item_by_name(item_name: String, position: Vector2) -> Item:
	var item = create_item_by_name(item_name)
	item.position = position
	add_child(item)
	items.append(item)
	
	return item	
	
func create_item_by_name(item_name: String):
	var item: PackedScene = load("res://world/item/" + item_name + ".tscn")
	return item.instantiate()

func find_nearest_item(item_type: Item.ItemType, pawn_position):
	var nearest_distance = 99999
	var nearest_item = null
	
	var filtered_items = items.filter(func(item: Item): return item.type == item_type)

	if item_type == Item.ItemType.FOOD:
		filtered_items.sort_custom(func(a: Food, b: Food): return a.nutrition > b.nutrition)
		filtered_items = filtered_items.filter(func(food: Food): return food.nutrition >= filtered_items[0].nutrition)
		
	for item: Item in filtered_items:
		if item.type == item_type:
			var distance = item.position.distance_to(pawn_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_item = item
			
	return nearest_item
	
func remove_item(item):
	items.erase(item)
	item.queue_free()

