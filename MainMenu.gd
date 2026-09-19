extends Control


@onready var options_panel: Panel = $OptionsPanel
@onready var click_sfx: AudioStreamPlayer = $ClickSFX if has_node("ClickSFX") else null

@onready var car_mode_btn: Button = $OptionsPanel/VBox/VehicleRow/CarModeButton if has_node("OptionsPanel/VBox/VehicleRow/CarModeButton") else null
@onready var bike_mode_btn: Button = $OptionsPanel/VBox/VehicleRow/BikeModeButton if has_node("OptionsPanel/VBox/VehicleRow/BikeModeButton") else null
@onready var one_player_btn: Button = $OptionsPanel/VBox/PlayersRow/OnePlayerButton if has_node("OptionsPanel/VBox/PlayersRow/OnePlayerButton") else null
@onready var two_player_btn: Button = $OptionsPanel/VBox/PlayersRow/TwoPlayerButton if has_node("OptionsPanel/VBox/PlayersRow/TwoPlayerButton") else null
@onready var laps3_btn: Button = $OptionsPanel/VBox/LapRows/Laps3Button if has_node("OptionsPanel/VBox/LapRows/Laps3Button") else null
@onready var laps5_btn: Button = $OptionsPanel/VBox/LapRows/Lap5Button if has_node("OptionsPanel/VBox/LapRows/Laps5Button") else null
@onready var lap7_btn: Button = $OptionsPanel/VBox/LapRows/Lap7Button if has_node("OptionsPanel/VBox/LapsRows/Laps7Button") else null
@onready var volume_slider: HSlider = $OptionsPanel/VBox/VolumeRow/VolumeSlider if has_node("OptionsPanel/VBox/VolumeRow/VolumeSlider") else null


func _ready() -> void:
	if options_panel:
		options_panel.hide()
	if volume_slider:
		volume_slider.value = GameManager.master_volume
	_refresh_option_button()

	
func _click() -> void:
	if click_sfx:
		click_sfx.play()
		
func _refresh_option_button() -> void:
	var selected := Color(1.0, 0.8, 0.25, 1)
	var unselected := Color(1, 1, 1, 1)
	if car_mode_btn:
		car_mode_btn.modulate = selected if GameManager.selected_vehicle == "car" else unselected
	if bike_mode_btn:
		bike_mode_btn.modulate = selected if GameManager.selected_vehicle == "bike" else unselected
	if one_player_btn:
		one_player_btn.modulate = selected if GameManager.single_player else unselected
	if two_player_btn:
		two_player_btn.modulate = selected if not GameManager.single_player else unselected
	if laps3_btn:
		laps3_btn.modulate = selected if GameManager.max_laps == 3 else unselected
	if laps5_btn:
		laps5_btn.modulate = selected if GameManager.max_laps == 5 else unselected
	if lap7_btn:
		lap7_btn.modulate = selected if GameManager.max_laps == 7 else unselected
		

func _on_start_button_pressed() -> void:
	_click()
	GameManager.selected_vehicle = "car"
	get_tree().change_scene_to_file("res://Scenes/LevelSelect.tscn")
	
func _on_settings_pressed() -> void:
	_click()
	if options_panel:
		options_panel.show()
		
func _on_exit_button_pressed() -> void:
	_click()
	get_tree().quit()
	
		
func _on_how_to_play_button_pressed() -> void:
	_click()
	GameManager.pending_level_scene = ""
	get_tree().change_scene_to_file("res://Scenes/Tutorial.tscn")
	
	
func _on_options_button_pressed() -> void:
	_click()
	if options_panel:
		options_panel.show()
		
func _on_car_mode_button_pressed() -> void:
	_click()
	GameManager.selected_vehicle = "car"
	_refresh_option_button()

func _on_bike_mode_button_pressed() -> void:
	_click()
	GameManager.selected_vehicle = "bike"
	_refresh_option_button()
	

func _on_one_player_button_pressed() -> void:
	_click()
	GameManager.single_player = true
	_refresh_option_button()


func _on_two_player_button_pressed() -> void:
	_click()
	GameManager.single_player = false
	_refresh_option_button()
	 
	
func _on_laps_3_button_pressed() -> void:
	_click()
	GameManager.max_laps = 3
	_refresh_option_button()


func _on_lap_5_button_pressed() -> void:
	_click()
	GameManager.max_laps = 5
	_refresh_option_button()


func _on_lap_7_button_pressed() -> void:
	_click()
	GameManager.max_laps = 7
	_refresh_option_button()

func _on_volume_slider_value_changed(value: float) -> void:
	GameManager.master_volume = value
	GameManager.apply_master_volune()
	

func _on_play_button_pressed() -> void:
	_click()
	get_tree().change_scene_to_file("res://Scenes/LevelSelect.tscn")
	
	
func _on_back_button_pressed() -> void:
	_click()
	if options_panel:
		options_panel.hide()
	
	
