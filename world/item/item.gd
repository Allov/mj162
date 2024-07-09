class_name Item
extends Node2D

@export var type: ItemType
@export var item_name: String

var in_storage = false
var storage: Storage = null

enum ItemType { FOOD, VEGETATION, ANIMAL, BUILDING, MATERIAL }

func get_item_type_name():
	match type:
		ItemType.FOOD:
			return "Food"
		ItemType.VEGETATION:
			return "Vegetation"
		ItemType.ANIMAL:
			return "Animal"
		ItemType.BUILDING:
			return "Building"
		ItemType.MATERIAL:
			return "Material"
		
func _process(_delta):
	visible = not in_storage
