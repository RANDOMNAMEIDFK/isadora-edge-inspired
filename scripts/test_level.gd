extends Node2D

func _ready():
	# Set up the test level with platforms
	setup_level()

func setup_level():
	# This is a basic test level
	# The actual platforms and collisions are set up in the scene
	pass

func _process(delta: float) -> void:
	# Check if player fell off the map
	if has_node("Player"):
		var player = $Player
		if player.global_position.y > 600:
			# Reset player position
			player.global_position = Vector2(100, 300)
			player.velocity = Vector2.ZERO
