extends CanvasLayer

@export var hearts := 3
@onready var hearts_container = $Control/MarginContainer/VBoxContainer/HBoxContainer
const HEART_ICON = preload("res://items/hear_icon/heart_icon.tscn")

func _ready():
	set_hearts(hearts)

func set_hearts (value: int) -> void:
	hearts = value
	
	for child in hearts_container.get_children():
		child.queue_free()
	
	if value > 0:
		for i in value:
			var control = Control.new()
			var icon = HEART_ICON.instantiate()
			icon.scale = Vector2i(5, 5)
			control.add_child(icon)
			hearts_container.add_child(control)
