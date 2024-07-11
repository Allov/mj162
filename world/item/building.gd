class_name Building
extends Item

@export var max_health = 100.0
@export var drop_item_name = ""
@export var mat_1_name: String
@export var mat_1_quantiy: int
@export var mat_2_name: String
@export var mat_2_quantiy: int

@export var mats: Dictionary
@onready var health = max_health
@onready var select_area = $SelectArea
@onready var sprite = $Sprite2D
@onready var health_bar = $HealthBar

var blue_print = false

func _ready():
	select_area.connect("input_event", _on_select_area_input_event)

func _process(_delta):
	health_bar.visible = health != max_health
	health_bar.value = health / max_health
	
	if blue_print:
		modulate.a = 0.5
	else:
		modulate.a = 1.0
		
func _on_select_area_input_event(_viewport, event: InputEvent, _shape):
	if not blue_print and event.is_action_pressed("click"):
		sprite.modulate = Color.PURPLE
		OrderManager.place_order([self])
