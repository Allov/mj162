class_name Vegetation
extends Item

@export var max_health = 100.0
@export var drop_item_name = ""
@export var drop_quantity = 1
@onready var health = max_health
@onready var select_area = $SelectArea
@onready var sprite = $Sprite2D
@onready var health_bar = $HealthBar

var being_harvested = false

func _ready():
	select_area.connect("input_event", _on_select_area_input_event)

func _process(_delta):
	health_bar.visible = health != max_health
	health_bar.value = health / max_health

func _on_select_area_input_event(_viewport, event: InputEvent, _shape):
	if not being_harvested and event.is_action_pressed("click") and drop_item_name != "":
		sprite.modulate = Color.YELLOW
		being_harvested = true
		OrderManager.place_harvest_order([self])
