extends Node

class_name LevelManager

# Level data structure
var current_level_data: Dictionary = {}
var levels: Dictionary = {}

func _ready():
	load_all_levels()

func create_level(level_name: String, width: int, height: int) -> Dictionary:
	var level_data = {
		"name": level_name,
		"width": width,
		"height": height,
		"tiles": [],
		"enemies": [],
		"spawn_point": Vector2(50, 300),
		"platforms": []
	}
	levels[level_name] = level_data
	return level_data

func save_level(level_name: String) -> void:
	var path = "user://levels/" + level_name + ".json"
	var dir = DirAccess.open("user://levels")
	if dir == null:
		DirAccess.make_abs_absolute("user://levels")
	
	var json = JSON.stringify(levels[level_name])
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(json)
		print("Level saved: ", path)

func load_level(level_name: String) -> Dictionary:
	var path = "user://levels/" + level_name + ".json"
	if ResourceLoader.exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var error = json.parse(file.get_as_text())
			if error == OK:
				current_level_data = json.data
				return json.data
	return {}

func load_all_levels() -> void:
	var dir_path = "user://levels"
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				var level_name = file_name.trim_suffix(".json")
				load_level(level_name)
			file_name = dir.get_next()

func export_level_as_string(level_name: String) -> String:
	if level_name in levels:
		return JSON.stringify(levels[level_name])
	return ""

func import_level_from_string(json_string: String, level_name: String) -> bool:
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		levels[level_name] = json.data
		save_level(level_name)
		return true
	return false
