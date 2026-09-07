extends Control

func _ready():
	$VBoxContainer/PlayBtn.pressed.connect(_on_play)
	$VBoxContainer/EditorBtn.pressed.connect(_on_editor)
	$VBoxContainer/QuitBtn.pressed.connect(_on_quit)

func _on_play():
	get_tree().change_scene_to_file("res://scenes/test_level.tscn")

func _on_editor():
	get_tree().change_scene_to_file("res://scenes/level_editor.tscn")

func _on_quit():
	get_tree().quit()
