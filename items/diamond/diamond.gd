extends CharacterBody2D
class_name Diamond

signal pickuped(diamond: Diamond)

@onready var area_2d = $Area2D
@onready var animation_player = $AnimationPlayer

const SPEED = 300.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	velocity.y = -300

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func _on_area_2d_body_entered(body):
	pickuped.emit(self)

func pickup ():
	animation_player.play('pickup')
	await animation_player.animation_finished
	queue_free()
