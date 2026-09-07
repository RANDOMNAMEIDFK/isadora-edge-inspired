extends Control

func _ready():
	$VBoxContainer/PlayBtn.pressed.connect(_on_play)
	$VBoxContainer/EditorBtn.pressed.connect(_on_editor)
	$VBoxContainer/QuitBtn.pressed.connect(_on_quit)

func _on_play():
	get_tree().change_scene_to_file("res://scenes/test_level.tscn")

func _on_editor():
	# Editor disabled for web - use export/import instead
	var dialog = AlertDialog.new()
	var label = Label.new()
	label.text = "Level Editor is not available on web.\nUse desktop version to create levels."
	add_child(dialog)
	dialog.popup_centered_ratio(0.6)

func _on_quit():
	get_tree().quit()
