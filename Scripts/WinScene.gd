extends Control

func _on_restart_button_pressed() -> void:
	# Change "res://Track.tscn" to the actual file path of your track scene!
	get_tree().change_scene_to_file("res://Track.tscn")
