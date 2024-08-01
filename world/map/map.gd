class_name Map
extends Node2D

@export var width = 100
@export var height = 100
@export var seed_name = "sapin"

@onready var tile_map: TileMap = $Terrain


enum TileType { SAND, WATER, RED_SAND, DIRT, ROCK, DEEP_WATER }
var tiles_coords = {}
var spawn_position = Vector2.ZERO

func _ready():
	var generation_start_item = Time.get_ticks_msec()
	
	tiles_coords[TileType.SAND] = Vector2i(0, 0)
	tiles_coords[TileType.WATER] = Vector2i(1, 0)
	tiles_coords[TileType.RED_SAND] = Vector2i(2, 0)
	tiles_coords[TileType.DIRT] = Vector2i(3, 0)
	tiles_coords[TileType.ROCK] = Vector2i(4, 0)
	tiles_coords[TileType.DEEP_WATER] = Vector2i(5, 0)

	var rng = RandomNumberGenerator.new()
	rng.seed = seed_name.hash()
	
	var noise = FastNoiseLite.new()
	noise.seed = seed_name.hash()
	noise.frequency = 0.008
	# noise.fractal_weighted_strength = .1
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	#noise.domain_warp_enabled = true
	#noise.domain_warp_type = FastNoiseLite.DOMAIN_WARP_SIMPLEX_REDUCED
	var dirt_cells: Array[Vector2i] = []
	for y in height:
		for x in width:
			var value = noise.get_noise_2d(x, y)
			
			var flip_flag = 0
			if randf() > 0.5:
				flip_flag = TileSetAtlasSource.TRANSFORM_FLIP_H
			elif randf() > 0.5:
				flip_flag = TileSetAtlasSource.TRANSFORM_FLIP_V
			elif randf() > 0.5:
				flip_flag = TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_FLIP_H

			if value < -0.6:
				tile_map.set_cell(0, Vector2i(x, y), 0, tiles_coords[TileType.DEEP_WATER])
			elif value >= -0.6 and value < 0:
				tile_map.set_cell(0, Vector2i(x, y), 0, tiles_coords[TileType.WATER])
				if rng.randf() < 0.01:
					ItemManager.spawn_item_by_name("fish", Vector2(x * 16, y * 16))
				elif rng.randf() < 0.01:
					ItemManager.spawn_item_by_name("waterlily", Vector2(x * 16, y * 16))
				elif rng.randf() < 0.01:
					ItemManager.spawn_item_by_name("seaweed", Vector2(x * 16, y * 16))
			elif value >= 0 and value < 0.4:
				# tile_map.set_cell(0, Vector2i(x, y), 0, tiles_coords[TileType.DIRT], 0 | flip_flag)
				# 
				dirt_cells.append(Vector2i(x, y))
				if rng.randf() < 0.01:
					ItemManager.spawn_item_by_name("berry_bush", Vector2(x * 16, y * 16))
				elif rng.randf() < 0.1:
					ItemManager.spawn_item_by_name("tree", Vector2(x * 16, y * 16))
				elif rng.randf() < 0.001:
					ItemManager.spawn_item_by_name("cow", Vector2(x * 16, y * 16))
			elif value >= 0.4 and value < 0.8:
				tile_map.set_cell(0, Vector2i(x, y), 0, tiles_coords[TileType.SAND])
				if rng.randf() < 0.001:
					ItemManager.spawn_item_by_name("skeleton", Vector2(x * 16, y * 16))
			elif value >= 0.8 and value < 0.9:
				tile_map.set_cell(0, Vector2i(x, y), 0, tiles_coords[TileType.RED_SAND])
				if rng.randf() < 0.001:
					ItemManager.spawn_item_by_name("skeleton", Vector2(x * 16, y * 16))
			else:
				tile_map.set_cell(0, Vector2i(x, y), 0, tiles_coords[TileType.ROCK])

	tile_map.set_cells_terrain_connect(0, dirt_cells, 0, 0)	

	print("map seed '" + seed_name + "' (" + str(width) + ", " + str(height) + ") generated in " + str(Time.get_ticks_msec() - generation_start_item) + " ms")
	
	
	# try and find a suitable spawn
	var found_spawn = false
	var center = Vector2i(width / 2, height / 2)
	var bounding_box = Rect2i(center, Vector2i(10, 10))
	var suitable_cells_count = 0
	var spawn_time = Time.get_ticks_msec()
	var box_size = 10
	while not found_spawn:
		for y in range(bounding_box.position.y, bounding_box.end.y):
			for x in range(bounding_box.position.x, bounding_box.end.x):
				# var source_id = tile_map.get_cell_source_id(0, Vector2i(x, y))
				var atlas_coords = tile_map.get_cell_atlas_coords(0, Vector2i(x, y))
				if atlas_coords not in [tiles_coords[TileType.WATER], tiles_coords[TileType.DEEP_WATER]]:
					suitable_cells_count += 1
		
		found_spawn = suitable_cells_count / bounding_box.get_area() > 0.9
		
		
		if not found_spawn:
			center = Vector2i(randi_range(box_size, width - box_size), randi_range(box_size, height - box_size))
			bounding_box = Rect2i(center, Vector2i(box_size, box_size))
	
	print("found spawn in " + str(Time.get_ticks_msec() - spawn_time) + " ms")
	
	var spawn_item_time = Time.get_ticks_msec()
	
	var spawn_items = ["meat", "wood", "bone"]
	var count = 25

	for i in count:
		var kind = spawn_items[rng.randi_range(0, spawn_items.size() - 1)]
		ItemManager.spawn_item_by_name(kind, Vector2(randi_range(center.x, center.x + bounding_box.size.x), randi_range(center.y, center.y + bounding_box.size.y)) * 16)

	print("spawned " + str(count) + " items in " + str(Time.get_ticks_msec() - spawn_item_time) + " ms")
		
	

	var pawns = [$Pawn, $Pawn2, $Pawn3]
	for pawn in pawns:
		pawn.global_position = center * 16
		
	spawn_position = center * 16
	
	print(str(pawns.size()) + " pawns arrived, say hello!")
	
	

func _process(_delta):
	pass

