extends Control

class_name LevelEditor

var level_manager: LevelManager = LevelManager.new()
var current_level_name: String = ""
var current_tool: int = 0  # 0: Platform, 1: Enemy, 2: Spawn
var current_size: Vector2 = Vector2(32, 32)
var grid_size: int = 16
var platforms: Array = []
var enemies: Array = []
var spawn_point: Vector2 = Vector2(50, 300)

@onready var level_name_input = $VBoxContainer/HBoxContainer/LevelNameInput
@onready var tool_selector = $VBoxContainer/HBoxContainer2/ToolSelector
@onready var size_x = $VBoxContainer/HBoxContainer2/SizeX
@onready var size_y = $VBoxContainer/HBoxContainer2/SizeY
@onready var canvas = $VBoxContainer/EditorContainer/Canvas/VBoxContainer/Control
@onready var platform_count = $VBoxContainer/EditorContainer/RightPanel/VBoxContainer/PlatformCount
@onready var enemy_count = $VBoxContainer/EditorContainer/RightPanel/VBoxContainer/EnemyCount
@onready var export_dialog = $ExportDialog
@onready var export_text = $ExportDialog/ExportText

func _ready():
	$VBoxContainer/HBoxContainer/NewLevelBtn.pressed.connect(_on_new_level)
	$VBoxContainer/HBoxContainer/SaveLevelBtn.pressed.connect(_on_save_level)
	$VBoxContainer/HBoxContainer/ExportBtn.pressed.connect(_on_export_level)
	$VBoxContainer/HBoxContainer/ImportBtn.pressed.connect(_on_import_level)
	$VBoxContainer/HBoxContainer/CopyPathBtn.pressed.connect(_on_copy_path)
	$VBoxContainer/HBoxContainer2/ClearBtn.pressed.connect(_on_clear_level)
	
	tool_selector.item_selected.connect(_on_tool_changed)
	canvas.gui_input.connect(_on_canvas_input)
	export_dialog.confirmed.connect(_on_export_confirmed)

	# Draw initial canvas
	canvas.draw.connect(_on_canvas_draw)

	# Test level
	_on_new_level()

func _on_new_level():
	var name_text = level_name_input.text.strip_edges()
	if name_text == "":
		name_text = "Level_" + str(randi_range(1000, 9999))
	
	current_level_name = name_text
	level_name_input.text = name_text
	level_manager.create_level(name_text, 1024, 600)
	platforms.clear()
	enemies.clear()
	spawn_point = Vector2(50, 300)
	
	# Add default ground
	platforms.append({"pos": Vector2(0, 550), "size": Vector2(1024, 50)})
	
	canvas.queue_redraw()
	update_stats()

func _on_save_level():
	if current_level_name == "":
		return
	
	var level_data = {
		"name": current_level_name,
		"platforms": platforms,
		"enemies": enemies,
		"spawn_point": {"x": spawn_point.x, "y": spawn_point.y}
	}
	
	level_manager.levels[current_level_name] = level_data
	level_manager.save_level(current_level_name)
	print("Level saved: ", current_level_name)

func _on_export_level():
	var level_data = {
		"name": current_level_name,
		"platforms": platforms,
		"enemies": enemies,
		"spawn_point": {"x": spawn_point.x, "y": spawn_point.y}
	}
	
	var json_string = JSON.stringify(level_data)
	export_text.text = json_string
	export_dialog.popup_centered_ratio(0.8)

func _on_export_confirmed():
	var json_string = export_text.text
	DisplayServer.clipboard_set(json_string)
	print("Level JSON copied to clipboard!")

func _on_import_level():
	var json_string = DisplayServer.clipboard_get()
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK and json.data is Dictionary:
		var data = json.data
		current_level_name = data.get("name", "Imported_Level")
		platforms = data.get("platforms", [])
		enemies = data.get("enemies", [])
		
		var spawn = data.get("spawn_point", {"x": 50, "y": 300})
		spawn_point = Vector2(spawn.get("x", 50), spawn.get("y", 300))
		
		level_name_input.text = current_level_name
		canvas.queue_redraw()
		update_stats()
		print("Level imported!")
	else:
		print("Invalid JSON")

func _on_copy_path():
	var path = OS.get_user_data_dir() + "/levels/" + current_level_name + ".json"
	DisplayServer.clipboard_set(path)
	print("Level path copied: ", path)

func _on_clear_level():
	if current_level_name == "":
		return
	
	platforms.clear()
	enemies.clear()
	spawn_point = Vector2(50, 300)
	
	# Add default ground
	platforms.append({"pos": Vector2(0, 550), "size": Vector2(1024, 50)})
	
	canvas.queue_redraw()
	update_stats()

func _on_tool_changed(index: int):
	current_tool = index

func _on_canvas_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		var pos = snap_to_grid(event.position)
		
		match current_tool:
			0:  # Platform
				platforms.append({"pos": pos, "size": current_size})
			1:  # Enemy
				enemies.append({"pos": pos})
			2:  # Spawn Point
				spawn_point = pos
		
		canvas.queue_redraw()
		update_stats()
	
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		# Right click to remove
		var pos = event.position
		
		for i in range(platforms.size() - 1, -1, -1):
			var platform = platforms[i]
			var rect = Rect2(platform["pos"], platform["size"])
			if rect.has_point(pos):
				platforms.remove_at(i)
				canvas.queue_redraw()
				update_stats()
				break
		
		for i in range(enemies.size() - 1, -1, -1):
			var enemy = enemies[i]
			var circle = CircleShape2D.new()
			circle.radius = 16
			if circle.get_rect().has_point(pos - enemy["pos"]):
				enemies.remove_at(i)
				canvas.queue_redraw()
				update_stats()
				break

func snap_to_grid(pos: Vector2) -> Vector2:
	return (pos / grid_size).round() * grid_size

func _on_canvas_draw():
	# Draw grid
	for x in range(0, 750, grid_size):
		canvas.draw_line(Vector2(x, 0), Vector2(x, 500), Color(0.2, 0.2, 0.2, 0.3))
	for y in range(0, 500, grid_size):
		canvas.draw_line(Vector2(0, y), Vector2(750, y), Color(0.2, 0.2, 0.2, 0.3))
	
	# Draw platforms
	for platform in platforms:
		var rect = Rect2(platform["pos"], platform["size"])
		canvas.draw_rect(rect, Color.GREEN)
		canvas.draw_rect(rect, Color.WHITE, false, 2.0)
	
	# Draw enemies
	for enemy in enemies:
		var pos = enemy["pos"]
		canvas.draw_circle(pos, 8, Color.RED)
		
	# Draw spawn point
	canvas.draw_circle(spawn_point, 6, Color.BLUE)
	
	# Draw info text
	canvas.draw_string(ThemeDB.fallback_font, Vector2(10, 20), "Left-click: Place | Right-click: Remove", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

func update_stats():
	size_x.value = current_size.x
	size_y.value = current_size.y
	current_size = Vector2(size_x.value, size_y.value)
	
	platform_count.text = "Platforms: " + str(platforms.size())
	enemy_count.text = "Enemies: " + str(enemies.size())
