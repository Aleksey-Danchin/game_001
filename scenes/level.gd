extends Node2D

@onready var level_01 = $Level01
@onready var human_king = $HumanKing

# Called when the node enters the scene tree for the first time.
func _ready():
	human_king.position = level_01.start_positon.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
