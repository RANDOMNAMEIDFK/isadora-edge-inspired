extends Camera2D

class_name CameraController

@export var follow_smoothness: float = 0.1
@export var zoom_smoothness: float = 0.1
@export var default_zoom: float = 1.5

var target_zoom: float = default_zoom
var player: Player = null

func _ready():
	player = get_parent()
	zoom = Vector2(default_zoom, default_zoom)

func _physics_process(delta: float) -> void:
	if player:
		# Smooth follow
		global_position = global_position.lerp(player.global_position, follow_smoothness)
		
		# Smooth zoom
		zoom = zoom.lerp(Vector2(target_zoom, target_zoom), zoom_smoothness)

func set_zoom_level(new_zoom: float, duration: float = 0.3) -> void:
	target_zoom = new_zoom
	await get_tree().create_timer(duration).timeout