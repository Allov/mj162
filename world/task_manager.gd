extends Node

var tasks: Array[Task] = []
var rng = RandomNumberGenerator.new()

func request_task() -> Task:
	if tasks.size() > 0:
		var task = tasks[0]
		tasks.erase(task)
		return task
	
	if rng.randf() < 0.005:
		return create_wander_task()
		
	return null

func request_find_and_eat_food() -> Task:
	return create_find_food_task()

func add_task(task: Task):
	tasks.append(task)

# Task Factory
func create_find_food_task() -> Task:
	var task = Task.new()
	task.type = Task.TaskType.FIND_FOOD
	
	var sub_task = Task.new()
	sub_task.type = Task.TaskType.EAT
	task.sub_tasks.append(sub_task)
	
	return task
	
func create_find_order_task() -> Task:
	var task = Task.new()
	task.type = Task.TaskType.FIND_ORDER
	
	var sub_task = Task.new()
	sub_task.type = Task.TaskType.HARVEST
	task.sub_tasks.append(sub_task)
	
	return task
	
func create_wander_task() -> Task:
	var task = Task.new()
	task.type = Task.TaskType.WANDER
	
	return task
	
	
	
