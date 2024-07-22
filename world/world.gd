extends Node2D

@onready var human_king = $HumanKing
@onready var player_mobile_controller = $PlayerMobileController
@onready var level = $Level
@onready var diamonds = $Diamonds
@onready var stats = $Stats

const DIAMOND = preload("res://items/diamond/diamond.tscn")

func _ready():
	human_king.hitted.connect(king_hit)
	human_king.hurted.connect(king_hurt)
	box_prepare()
	mobs_prepare()

func box_prepare():
	for box in level.boxes.get_children():
		box.broken.connect(box_broken)
	
func mobs_prepare():
	for mob in level.mobs.get_children():
		mob.hitted.connect(pig_hit)

func king_hit():
	var hitbox: Area2D = human_king.hit_box
	
	if not hitbox.has_overlapping_bodies():
		return
	
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		if body.has_method('hurt'):
			body.call('hurt')

func box_broken(position: Vector2):
	var diamond = DIAMOND.instantiate()
	diamond.position = position
	diamonds.add_child(diamond)
	diamond.pickuped.connect(diamon_pickup)

func diamon_pickup(diamond: Diamond):
	diamond.pickup()

func pig_hit(pig: Pig):
	human_king.hurt(pig.hitbox_shape)

func king_hurt(damage: int):
	stats.set_hearts(human_king.health_component.health)
