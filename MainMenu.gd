extends Control

@onready var options_panel: Panel = $OptionsPanel

func _ready() -> void:
	if options_panel:
		options_panel.hide()

func _on_start_pressed() -> void:
	GameManager.selected_vehicle = "car"
	get_tree().change_scene_to_file("res://Scripts/Track.tscn")

func _on_settings_pressed() -> void:
	if options_panel:
		options_panel.show()

func _on_exit_pressed() -> void:
	get_tree().quit()

# --- Options Menu Buttons ---

func _on_options_button_pressed() -> void:
	if options_panel:
		options_panel.show()

func _on_car_mode_button_pressed() -> void:
	GameManager.selected_vehicle = "car"
	get_tree().change_scene_to_file("res://Scripts/Track.tscn")

func _on_bike_mode_button_pressed() -> void:
	GameManager.selected_vehicle = "bike"
	get_tree().change_scene_to_file("res://Scripts/Track.tscn")

func _on_back_button_pressed() -> void:
	if options_panel:
		options_panel.hide()
