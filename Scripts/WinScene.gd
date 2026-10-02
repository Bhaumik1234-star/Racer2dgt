extends Control
# Handles UI interactions for restarting or returning to the main menu screen

# Reference to the start audio stream player node
@onready var button_pressed = $PressStart

# Called when the restart button is clicked to return to the main menu scene	
func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
