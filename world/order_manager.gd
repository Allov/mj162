extends Node

func place_order(items: Array[Item]):
	for item: Item in items:
		var task: Task = TaskManager.create_find_order_task()
		task.target_item = item
		TaskManager.add_task(task)
