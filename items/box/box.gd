extends CharacterBody2D
class_name Box

signal broken(position: Vector2)

enum STATE { IDLE, HURT, DEAD }

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var state: STATE = STATE.IDLE
var is_hurted := false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var health_component = $HealthComponent
@onready var parts = $Parts

func _ready ():
	remove_child(parts)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	match state:
		STATE.IDLE:
			idle_state()
		STATE.HURT:
			hurt_state()
		STATE.DEAD:
			dead_state()

	move_and_slide()

func idle_state():
	animated_sprite_2d.play("idle")
	
	if not is_hurted:
		return
	
	health_component.health -= 1
	if health_component.health > 0:
		state = STATE.HURT
	else:
		state = STATE.DEAD

func hurt_state():
	animated_sprite_2d.play("hurt")
	await animated_sprite_2d.animation_finished
	state = STATE.IDLE
	is_hurted = false

func dead_state():
	broken.emit(position)
	health_component.is_alive = false
	var tween = get_tree().create_tween().set_parallel(true)
	var parent = get_parent()
	parent.remove_child(self)
	parent.add_child(parts)
	parts.position = position
	for part in parts.get_children():
		var speed = randf_range(330, 450)
		var angle = deg_to_rad(randf_range(-45, 45) - 90)
		part.linear_velocity.x = speed * cos(angle)
		part.linear_velocity.y = speed * sin(angle)
		tween.tween_property(part, 'modulate:a', 0, 3)
	await tween.finished
	parent.remove_child(parts)

func hurt ():
	if not health_component.is_alive:
		return

	is_hurted = true
