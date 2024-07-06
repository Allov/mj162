class_name Animal
extends Item

@export var max_health = 100.0
@export var drop_item_name = ""
@onready var health = max_health
@onready var select_area = $SelectArea
@onready var sprite = $Sprite2D
@onready var health_bar = $HealthBar

func _ready():
	select_area.connect("input_event", _on_select_area_input_event)

func _process(delta):
	health_bar.visible = health != max_health
	health_bar.value = health / max_health

func _on_select_area_input_event(viewport, event: InputEvent, shape):
	if event.is_action_pressed("click"):
		sprite.modulate = Color.PURPLE
		OrderManager.place_order([self])
