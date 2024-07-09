class_name Storage
extends Building

@export var initial_inventory: Array[String] = []
@onready var debug_label = $DebugLabel

var inventory: Array[Item] = []

func _ready():
	for item_aname in initial_inventory:
		var item: Item = ItemManager.spawn_item_by_name(item_aname, Vector2.ZERO)
		item.in_storage = true
		inventory.append(item)
		
func _process(delta):
	super._process(delta)
	debug_label.text = ""
	debug_label.text += "inventory: %s" % inventory.size()
