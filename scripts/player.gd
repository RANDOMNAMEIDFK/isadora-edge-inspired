extends CharacterBody2D

class_name Player

# Movement
@export var move_speed: float = 200.0
@export var acceleration: float = 1000.0
@export var friction: float = 800.0
@export var jump_force: float = -400.0
@export var max_fall_speed: float = 500.0
@export var gravity: float = 1200.0

# Dash
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.5
var can_dash: bool = true
var is_dashing: bool = false
var dash_time: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

# Jumping
var is_jumping: bool = false
var jump_buffer_time: float = 0.1
var jump_buffer_counter: float = 0.0

# State
var is_on_wall: bool = false
var wall_slide_speed: float = 100.0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var animation_player = $AnimationPlayer

func _ready():
	pass

func _physics_process(delta: float) -> void:
	handle_input()
	
	if is_dashing:
		handle_dash(delta)
	else:
		handle_movement(delta)
		handle_jumping(delta)
	
	handle_wall_slide()
	move_and_slide()
	update_animation()

func handle_input() -> void:
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		start_dash()
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_counter = jump_buffer_time

func handle_movement(delta: float) -> void:
	var input_direction = Input.get_axis("ui_left", "ui_right")
	
	if input_direction != 0:
		velocity.x = move_toward(velocity.x, input_direction * move_speed, acceleration * delta)
		if sprite:
			sprite.flip_h = input_direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	
	# Apply gravity
	velocity.y = move_toward(velocity.y, max_fall_speed, gravity * delta)

func handle_jumping(delta: float) -> void:
	jump_buffer_counter -= delta
	
	if is_on_floor():
		is_jumping = false
		if jump_buffer_counter > 0:
			velocity.y = jump_force
			jump_buffer_counter = 0.0
			is_jumping = true

func handle_dash(delta: float) -> void:
	dash_time += delta
	velocity = dash_direction * dash_speed
	
	if dash_time >= dash_duration:
		is_dashing = false
		dash_time = 0.0
		can_dash = false
		await get_tree().create_timer(dash_cooldown).timeout
		can_dash = true

func start_dash() -> void:
	is_dashing = true
	var input_direction = Input.get_axis("ui_left", "ui_right")
	var input_vertical = Input.get_axis("ui_up", "ui_down")
	
	if input_direction != 0 or input_vertical != 0:
		dash_direction = Vector2(input_direction, input_vertical).normalized()
	else:
		dash_direction = Vector2(1 if not sprite.flip_h else -1, 0)

func handle_wall_slide() -> void:
	if not is_on_floor() and is_on_wall_only() and velocity.y > 0:
		is_on_wall = true
		velocity.y = move_toward(velocity.y, wall_slide_speed, gravity * 0.5 * get_physics_process_delta_time())
	else:
		is_on_wall = false

func update_animation() -> void:
	if animation_player:
		if is_dashing:
			animation_player.play("dash")
		elif is_on_wall:
			animation_player.play("wall_slide")
		elif is_jumping or not is_on_floor():
			animation_player.play("jump")
		elif velocity.x != 0:
			animation_player.play("run")
		else:
			animation_player.play("idle")