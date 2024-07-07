class_name Task
extends Node

signal task_done(task: Task)

@export var type: TaskType

enum TaskType { FIND_FOOD, EAT, FIND_HARVEST, HARVEST, WANDER, START_BUILDING_ORDER, FIND_BUILDING, GATHER_MATS, BUILD, ASSEMBLE }

var next_task: Task = null
var target_item: Item = null
var item_to_find: String = ""
var quantity_to_find: int = 0

func get_task_type_name():
	match type:
		TaskType.FIND_FOOD:
			return "finding food"
		TaskType.EAT:
			return "eating"
		TaskType.FIND_HARVEST:
			return "finding harvestable"
		TaskType.HARVEST:
			return "harvesting"
		TaskType.WANDER:
			return "wandering"
		TaskType.START_BUILDING_ORDER:
			return "start build"
		TaskType.FIND_BUILDING:
			return "finding building"
		TaskType.GATHER_MATS:
			return "gathering mats"
		TaskType.ASSEMBLE:
			return "assembling"
		TaskType.BUILD:
			return "building"

func request_next_task():
	if next_task != null:
		next_task.target_item = target_item
		return next_task
	else:
		task_done.emit(self)
	
	return null
