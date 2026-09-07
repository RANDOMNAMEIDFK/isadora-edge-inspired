extends CharacterBody2D

class_name Enemy

# Basic properties
@export var health: float = 20.0
@export var move_speed: float = 100.0
@export var gravity: float = 1200.0
@export var max_fall_speed: float = 500.0

# Combat
@export var attack_damage: float = 10.0
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.5

# Patrol
@export var patrol_distance: float = 150.0
@export var patrol_speed: float = 80.0

# State
var current_health: float
var is_attacking: bool = false
var attack_timer: float = 0.0
var patrol_direction: int = 1
var player: Player = null

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var detection_area = $DetectionArea2D

func _ready():
	current_health = health
	player = get_tree().root.get_child(0).get_node("Player") if "Player" in get_tree().root.get_child(0) else null

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if player and is_player_in_range():
		chase_player(delta)
	else:
		patrol(delta)
	
	update_attack(delta)
	move_and_slide()
	update_animation()

func apply_gravity(delta: float) -> void:
	velocity.y = move_toward(velocity.y, max_fall_speed, gravity * delta)

func is_player_in_range() -> bool:
	return player and global_position.distance_to(player.global_position) < attack_range * 3

func chase_player(delta: float) -> void:
	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * move_speed
	
	if direction != 0:
		sprite.flip_h = direction < 0

func patrol(delta: float) -> void:
	velocity.x = patrol_direction * patrol_speed
	sprite.flip_h = patrol_direction < 0

func update_attack(delta: float) -> void:
	if attack_timer > 0:
		attack_timer -= delta
	
	if is_player_in_range() and attack_timer <= 0 and not is_attacking:
		perform_attack()

func perform_attack() -> void:
	is_attacking = true
	attack_timer = attack_cooldown
	
	if animation_player.has_animation("attack"):
		animation_player.play("attack")
	
	if player:
		player.velocity += Vector2(sign(player.global_position.x - global_position.x) * 200, -100)
		player.health -= attack_damage
	
	await get_tree().create_timer(0.3).timeout
	is_attacking = false

func take_damage(damage: float) -> void:
	current_health -= damage
	if animation_player.has_animation("hit"):
		animation_player.play("hit")
	
	if current_health <= 0:
		die()

func die() -> void:
	if animation_player.has_animation("death"):
		animation_player.play("death")
		await animation_player.animation_finished
	
	queue_free()

func update_animation() -> void:
	if animation_player:
		if is_attacking:
			animation_player.play("attack")
		elif velocity.x != 0:
			animation_player.play("walk")
		else:
			animation_player.play("idle")