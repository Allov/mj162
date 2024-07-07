extends Node

func place_harvest_order(items: Array[Item]):
	for item: Item in items:
		var task: Task = TaskManager.create_harvest_task()
		task.target_item = item
		TaskManager.add_task(task)

func place_building_order(item: Building):
	var task: Task = TaskManager.create_build_task(item)
	item.health = 0
	
	TaskManager.add_task(task)
