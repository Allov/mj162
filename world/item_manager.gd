extends Node

var items: Array[Item] = []
var items_by_type = {}
var items_by_name = {}
var rng = randi()

func spawn_item_by_name(item_name: String, position: Vector2) -> Item:
	var item: Item = create_item_by_name(item_name) as Item
	item.position = position
	add_child(item)
	items.append(item)
	
	if items_by_type.has(item.type):
		items_by_type[item.type].append(item)
	else:
		items_by_type[item.type] = [item]
		
	if items_by_name.has(item_name):
		items_by_name[item_name].append(item)
	else:
		items_by_name[item_name] = [item]
		
	return item
	
func create_item_by_name(item_name: String):
	var item: PackedScene = load("res://world/item/" + item_name + ".tscn")
	return item.instantiate()

func find_nearest_items_by_type(item_types: Array[Item.ItemType], pawn_position, include_in_storage: bool = true):
	# var filtered_items = items.filter(func(item: Item): return item.type in item_types and (include_in_storage or not item.in_storage))
	var filtered_items = []
	for item_type in items_by_type.keys:
		if item_type in item_types:
			filtered_items = items_by_type[item_type].filter(func(item: Item): return include_in_storage or not item.in_storage)

	if Item.ItemType.FOOD in item_types and item_types.size() == 1:
		filtered_items.sort_custom(func(a: Food, b: Food): return a.nutrition > b.nutrition)
		filtered_items = filtered_items.filter(func(food: Food): return food.nutrition >= filtered_items[0].nutrition)
		
	return _find_nearest_item(filtered_items, pawn_position)

func find_nearest_item_by_type(item_type: Item.ItemType, pawn_position, include_in_storage: bool = true):
	return find_nearest_items_by_type([item_type], pawn_position, include_in_storage)
	
func find_nearest_item_by_name(item_name: String, pawn_position, include_in_storage: bool = true):
	var filtered_items = items.filter(func(item: Item): return item.item_name.to_lower().begins_with(item_name) and (include_in_storage or not item.in_storage))
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

func find_items_by_type(item_type: Item.ItemType):
	if items_by_type.has(item_type):
		return items_by_type[item_type]
	
	return []

func create_blue_print_by_name(item_name: String):
	var item: PackedScene = load("res://world/item/" + item_name + ".tscn")
	var created_item = item.instantiate()
	add_child(created_item)
	
	if created_item is Building:
		created_item.blue_print = true
		
	return created_item
	
func any(item_name: String):
	return items_by_name.has(item_name) and items_by_name[item_name].size() > 0
	
func any_types(item_types: Array[Item.ItemType], include_in_storage: bool):
	# var itms = items.filter(func(item: Item): return item.type in item_types and (include_in_storage or not item.in_storage))
	# return itms
	var found = false
	for key in items_by_type:
		if key in item_types:
			if not include_in_storage:
				var itms = items_by_type[key].filter(func(item: Item): return item.in_storage)
				found = itms.size() > 0
			else:
				found = true

	return found
	
func reserve_item(item: Item):
	items.erase(item)
	items_by_type[item.type].erase(item)
	
func remove_item(item: Item):
	reserve_item(item)

	if item.storage != null:
		item.storage.inventory.erase(item)
	item.queue_free()

