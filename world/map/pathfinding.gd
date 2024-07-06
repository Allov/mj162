class_name Pathfinding
extends Node2D

@onready var map = $".."
@onready var terrain = $"../Terrain"

var path: PackedVector2Array
var grid: AStarGrid2D = AStarGrid2D.new()

func _ready():
	await map.ready

	grid.region = Rect2(0, 0, map.width, map.height)
	grid.cell_size = Vector2(16, 16)
	grid.update()
	
	for x in map.width:
		for y in map.height:
			grid.set_point_weight_scale(Vector2i(x, y), get_tile_difficulty(Vector2i(x, y)))

	# request_path(Vector2.ZERO, Vector2(50, 33))
	
func request_path(start: Vector2, end: Vector2):
	path = grid.get_point_path(start, end)
	# queue_redraw()
	return path

func get_tile_difficulty(pos: Vector2i):
	var layer = 0
	var source_id = terrain.get_cell_source_id(layer, pos)
	var source = terrain.tile_set.get_source(source_id)
	var coords = terrain.get_cell_atlas_coords(layer, pos)
	var data = source.get_tile_data(coords, 0)
	
	return data.get_custom_data("difficulty")
	
func _process(_delta):
	pass
	
func _draw():
	if path.size() > 0:
		for i in path.size() - 1:
			draw_line(path[i] + Vector2(8, 8), path[i+1] + Vector2(8, 8), Color.WHITE_SMOKE)
