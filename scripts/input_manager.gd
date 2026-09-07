extends Node

class_name InputManager

# Action mappings
const MOVE_LEFT = "ui_left"
const MOVE_RIGHT = "ui_right"
const MOVE_UP = "ui_up"
const MOVE_DOWN = "ui_down"
const JUMP = "jump"
const DASH = "dash"
const ATTACK_LIGHT = "attack_light"
const ATTACK_HEAVY = "attack_heavy"
const INTERACT = "interact"

func _ready():
	setup_input_map()

func setup_input_map():
	# Check if actions exist, if not create them
	if not InputMap.has_action(JUMP):
		InputMap.add_action(JUMP)
		var key = InputEventKey.new()
		key.keycode = KEY_SPACE
		InputMap.action_add_event(JUMP, key)
		InputMap.action_set_deadzone(JUMP, 0.0)
	
	if not InputMap.has_action(DASH):
		InputMap.add_action(DASH)
		var key = InputEventKey.new()
		key.keycode = KEY_SHIFT
		InputMap.action_add_event(DASH, key)

func get_movement_input() -> Vector2:
	return Vector2(
		Input.get_axis(MOVE_LEFT, MOVE_RIGHT),
		Input.get_axis(MOVE_UP, MOVE_DOWN)
	)

func is_jumping() -> bool:
	return Input.is_action_just_pressed(JUMP)

func is_dashing() -> bool:
	return Input.is_action_just_pressed(DASH)

func is_attacking_light() -> bool:
	return Input.is_action_just_pressed(ATTACK_LIGHT)

func is_attacking_heavy() -> bool:
	return Input.is_action_just_pressed(ATTACK_HEAVY)

func is_interacting() -> bool:
	return Input.is_action_just_pressed(INTERACT)
