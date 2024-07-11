class_name Map
extends Node2D

@export var width = 100
@export var height = 100
@export var seed_name = "sapin"

@onready var tile_map: TileMap = $Terrain


enum TileType { SAND, WATER, RED_SAND, DIRT, ROCK, DEEP_WATER }
var tiles_coords = {}

func _ready():
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
			elif value >= -0.6 and value < -0.4:
				tile_map.set_cell(0, Vector2i(x, y), 0, tiles_coords[TileType.WATER])
				if rng.randf() < 0.01:
					ItemManager.spawn_item_by_name("fish", Vector2(x * 16, y * 16))
				elif rng.randf() < 0.01:
					ItemManager.spawn_item_by_name("waterlily", Vector2(x * 16, y * 16))
				elif rng.randf() < 0.01:
					ItemManager.spawn_item_by_name("seaweed", Vector2(x * 16, y * 16))
			elif value >= -0.4 and value < -0.2:
				# tile_map.set_cell(0, Vector2i(x, y), 0, tiles_coords[TileType.DIRT], 0 | flip_flag)
				# 
				dirt_cells.append(Vector2i(x, y))
				if rng.randf() < 0.01:
					ItemManager.spawn_item_by_name("berry_bush", Vector2(x * 16, y * 16))
				elif rng.randf() < 0.001:
					ItemManager.spawn_item_by_name("tree", Vector2(x * 16, y * 16))
				elif rng.randf() < 0.001:
					ItemManager.spawn_item_by_name("cow", Vector2(x * 16, y * 16))
			elif value >= -0.2 and value < 0.2:
				tile_map.set_cell(0, Vector2i(x, y), 0, tiles_coords[TileType.SAND])
				if rng.randf() < 0.001:
					ItemManager.spawn_item_by_name("skeleton", Vector2(x * 16, y * 16))
			elif value >= 0.2 and value < 0.6:
				tile_map.set_cell(0, Vector2i(x, y), 0, tiles_coords[TileType.RED_SAND])
				if rng.randf() < 0.001:
					ItemManager.spawn_item_by_name("skeleton", Vector2(x * 16, y * 16))
			else:
				tile_map.set_cell(0, Vector2i(x, y), 0, tiles_coords[TileType.ROCK])


	tile_map.set_cells_terrain_connect(0, dirt_cells, 0, 0)	
	var spawn_items = ["meat", "wood", "bone"]
	var count = 25
	var range = Vector2(0, 16)

	for i in count:
		var kind = spawn_items[rng.randi_range(0, spawn_items.size() - 1)]
		ItemManager.spawn_item_by_name(kind, Vector2(rng.randi_range(range.x, range.y) * 16, rng.randi_range(range.x, range.y) * 16))

func _process(_delta):
	pass

