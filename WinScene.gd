extends Control

@onready var press_start_button = $PressStart

func _ready() -> void:
	if press_start_button:
		press_start_button.pressed.connect(_on_press_start_pressed)

func _on_press_start_pressed() -> void:
	# Paste your track scene path inside the quotes below!
	var error = get_tree().change_scene_to_file("res://Track.tscn")
	
	if error != OK:
		print("ERROR: Couldn't reload track! Check the path to your Track scene.")
