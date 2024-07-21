extends CharacterBody2D

signal hitted ()

enum STATE { ATTACK, DEAD, DOOR_IN, DOOR_OUT, FALL, GROUND, HIT, IDLE, JUMP, RUN, HURT }

const MAX_SPEED = 150.0
const ACCELERATION = 500.0
const JUMP_VELOCITY = -350.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var camera_2d = $Camera2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hitbox_shape = $HitBox/CollisionShape2D
@onready var hit_box := $HitBox
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $HitBox/CollisionShape2D

var hurting := false

var state: STATE = STATE.IDLE

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_released("up") and velocity.y < 0:
		velocity.y = 0
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(
			velocity.x,
			MAX_SPEED * direction,
			ACCELERATION*delta
		)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)

	match state:
		STATE.ATTACK:
			attack_state()
		STATE.DEAD:
			dead_state()
		STATE.DOOR_IN:
			door_in_state()
		STATE.DOOR_OUT:
			door_out_state()
		STATE.FALL:
			fall_state()
		STATE.GROUND:
			ground_state()
		STATE.HIT:
			hit_state()
		STATE.IDLE:
			idle_state()
		STATE.JUMP:
			jump_state()
		STATE.RUN:
			run_state()
		STATE.HURT:
			hurt_state()
			
	if velocity.x < 0:
		face_left()
	elif velocity.x > 0:
		face_right()
		
	move_and_slide()
			
func attack_state ():
	#animated_sprite_2d.play('attack')
	animation_player.play("attack")
	
	velocity.x = 0
	await animated_sprite_2d.animation_finished
	state = STATE.IDLE

func dead_state ():
	pass

func door_in_state ():
	pass

func door_out_state ():
	pass

func fall_state ():
	animated_sprite_2d.play('fall')
	if is_on_floor():
		state = STATE.GROUND

func ground_state ():
	animated_sprite_2d.play('ground')
	await animated_sprite_2d.animation_finished
	state = STATE.IDLE

func hit_state ():
	pass

func idle_state ():
	animated_sprite_2d.play('idle')
	
	if Input.is_action_just_pressed('attack'):
		state = STATE.ATTACK
	elif velocity.y < 0:
		state = STATE.JUMP
	elif velocity.y > 0:
		state = STATE.FALL
	elif velocity.x != 0:
		state = STATE.RUN

func jump_state ():
	if velocity.y < 0:
		animated_sprite_2d.play('jump')
	elif not is_on_floor():
		state = STATE.FALL
	else:
		state = STATE.IDLE

func run_state ():
	animated_sprite_2d.play('run')
	
	if Input.is_action_just_pressed('attack'):
		state = STATE.ATTACK
	elif velocity == Vector2.ZERO:
		state = STATE.IDLE

func hurt_state():
	if not hurting:
		hurting = true
		animation_player.play('hurt')
		await animated_sprite_2d.animation_finished
		state = STATE.IDLE
		hurting = false

func hit():
	hitted.emit()

func face_left():
	animated_sprite_2d.flip_h = true
	animated_sprite_2d.position.x = -7
	collision_shape_2d.position.x = -35

func face_right():
	animated_sprite_2d.flip_h = false
	animated_sprite_2d.position.x = 7
	collision_shape_2d.position.x = 35

func hurt(hitbox: CollisionShape2D):
	velocity.y -= 200
	state = STATE.HURT
