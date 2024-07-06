class_name Task
extends Node

signal task_done(task: Task)

@export var type: TaskType

enum TaskType { FIND_FOOD, EAT, FIND_ORDER, HARVEST, WANDER }

var sub_tasks: Array[Task] = []
var target_item: Item = null

func request_sub_task():
	if sub_tasks.size() > 0:
		var next_task = sub_tasks[0]
		next_task.target_item = target_item
		sub_tasks.erase(next_task)
		return next_task
	else:
		task_done.emit(self)
