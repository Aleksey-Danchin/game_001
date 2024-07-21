extends CharacterBody2D
class_name Pig

signal hitted(pig: Pig)

enum { IDLE, FOLLOW, JUMP, FALL, GROUND, HIT, HURT, DEAD }
var state = IDLE

var target_follow: Node2D = null
var target_attack: Node2D = null
var attack_cooldown := 0.0
var attacking := false

const SPEED := 50.0
const JUMP_VELOCITY := -350.0
const ATTACK_COOLDOWN := 1.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var face_change_timeout = randf_range(1.0, 3.0)
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var collision_shape = $CollisionShape2D
@onready var health_component = $HealthComponent
@onready var animated_sprite = $AnimatedSprite2D
@onready var detector_collision_shape = $Detector/DetectorCollisionShape2D
@onready var detector = $Detector
@onready var hitbox = $HitBox
@onready var hitbox_shape = $HitBox/HitBoxShape
@onready var animation_player = $AnimationPlayer

func _ready():
	if [true, false].pick_random():
		face_left()
	else:
		face_right()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if velocity.y < 0:
		state = JUMP
	elif velocity.y > 0:
		state = FALL
		
	if attack_cooldown:
		attack_cooldown = max(attack_cooldown - delta, 0)
	
	match state:
		IDLE:
			idle_state()
		FOLLOW:
			follow_state()
		JUMP:
			jump_state()
		FALL:
			fall_state()
		GROUND:
			ground_state()
		HIT:
			hit_state()
		HURT:
			hurt_state()
		DEAD:
			dead_state()

	move_and_slide()

func hurt ():
	state = HURT

func face_left():
	animated_sprite.flip_h = false
	animated_sprite.position.x = -3
	detector_collision_shape.position.x = -50
	hitbox_shape.position.x = -13

func face_right():
	animated_sprite.flip_h = true
	animated_sprite.position.x = 3
	detector_collision_shape.position.x = 50
	hitbox_shape.position.x = 13

func _on_detector_body_entered(body):
	target_follow = body

func _on_detector_body_exited(body):
	target_follow = null

func idle_state():		
	animated_sprite.play('idle')
	
	if velocity.x != 0:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if target_attack:
		if attack_cooldown == 0:
			state = HIT
		return
	
	if target_follow:
		state = FOLLOW
		return
	
	var delta = get_physics_process_delta_time()
	face_change_timeout = max(face_change_timeout - delta, 0)
	if face_change_timeout == 0:
		face_change_timeout = randf_range(1.0, 3.0)
		if animated_sprite.flip_h:
			face_left()
		else:
			face_right()

func follow_state():
	if target_attack:
		state = IDLE
		return
	
	if target_follow:
		animated_sprite.play('run')
		var direction = target_follow.global_position - global_position
		direction = direction.normalized()
		velocity.x = direction.x * SPEED
		return
	
	state = IDLE

func jump_state():
	animated_sprite.play('jump')

func fall_state():
	animated_sprite.play('fall')
	if is_on_floor():
		state = GROUND

func ground_state():
	animated_sprite.play('ground')
	await animated_sprite.animation_finished
	state = IDLE

func hit_state():
	if not target_attack:
		state = IDLE
		return
	
	velocity.x = 0
	
	if not attacking:
		attacking = true
		animation_player.play('hit')
		await animation_player.animation_finished
		attack_cooldown = ATTACK_COOLDOWN
		attacking = false
		state = IDLE
		return

func hurt_state():
	velocity.y = -400	
	animated_sprite.play('hurt')
	await animated_sprite.animation_finished
	state = IDLE

func dead_state():
	pass

func _on_hit_box_body_entered(body):
	target_attack = body

func _on_hit_box_body_exited(body):
	target_attack = null

func hit():
	hitted.emit(self)
