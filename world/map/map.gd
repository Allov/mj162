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
	for y in height:
		for x in width:
			var value = noise.get_noise_2d(x, y)
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
				tile_map.set_cell(0, Vector2i(x, y), 0, tiles_coords[TileType.DIRT])
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
	
	var food_kinds = ["meat", "wood", "bone"]

	for i in 15:
		var kind = food_kinds[rng.randi_range(0, food_kinds.size() - 1)]
		ItemManager.spawn_item_by_name(kind, Vector2(rng.randi_range(0, 25) * 16, rng.randi_range(0, 25) * 16))

func _process(_delta):
	pass

