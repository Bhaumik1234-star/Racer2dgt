extends Node
class_name Track

var total_checkpoints: int = 3
var current_progress: int = 0

var max_laps: int = 3
var current_lap: int = 1
var is_game_over: bool = false

var can_trigger_start: bool = true

# Lap tracking per player
var p1_laps: int = 1
var p2_laps: int = 1

@onready var music_player = $CanvasLayer/MusicPlayer if has_node("CanvasLayer/MusicPlayer") else null
@onready var music_button = $CanvasLayer/MusicButton if has_node("CanvasLayer/MusicButton") else null
@onready var label = $CanvasLayer/Label if has_node("CanvasLayer/Label") else null
@onready var volume_slider = $CanvasLayer/VolumeSlider if has_node("CanvasLayer/VolumeSlider") else null

@onready var countdown_label = $CanvasLayer/CountdownLabel if has_node("CanvasLayer/CountdownLabel") else null
@onready var beep_tick_sfx = $CanvasLayer/BeepTickSFX if has_node("CanvasLayer/BeepTickSFX") else null
@onready var beep_go_sfx = $CanvasLayer/BeepGoSFX if has_node("CanvasLayer/BeepGoSFX") else null

@onready var player1 = $Background/Player1 if has_node("Background/Player1") else null
@onready var player2 = $Background/Player2 if has_node("Background/Player2") else null
@onready var dynamic_camera = $Background/DynamicCamera if has_node("Background/DynamicCamera") else null

# UI node references assigned safely in _ready()
var p1_speed_label: Label = null
var p1_speed_bar: Control = null
var p2_speed_label: Label = null
var p2_speed_bar: Control = null
var speed_panel_p2: Control = null


func _ready() -> void:
	if "max_laps" in GameManager:
		max_laps = GameManager.max_laps

	p1_speed_label = _get_ui_node(["CanvasLayer/SpeedPanel1/SpeedLabel", "CanvasLayer/SpeedPanelP1/SpeedLabel"])
	p1_speed_bar = _get_ui_node(["CanvasLayer/SpeedPanel1/BarBG/BarFill", "CanvasLayer/SpeedPanelP1/BarBG/BarFill"])
	
	p2_speed_label = _get_ui_node(["CanvasLayer/SpeedPanel2/SpeedLabel", "CanvasLayer/SpeedPanelP2/SpeedLabel"])
	p2_speed_bar = _get_ui_node(["CanvasLayer/SpeedPanel2/BarBG/BarFill", "CanvasLayer/SpeedPanelP2/BarBG/BarFill"])
	speed_panel_p2 = _get_ui_node(["CanvasLayer/SpeedPanelP2", "CanvasLayer/SpeedPanel2"])

	GameManager.apply_master_volume()
	
	if GameManager.single_player and player2:
		player2.visible = false
		player2.set_physics_process(false)
		player2.set_process(false)
		player2.monitoring = false
		player2.monitorable = false
		player2.remove_from_group("racers")
		if dynamic_camera:
			dynamic_camera.car2 = null
		if speed_panel_p2:
			speed_panel_p2.visible = false
	
	if volume_slider:
		_on_volume_slider_value_changed(volume_slider.value)
		
	update_lap_ui()
	_start_countdown()


func _process(_delta: float) -> void:
	_update_speedometer(player1, p1_speed_label, p1_speed_bar)
	_update_speedometer(player2, p2_speed_label, p2_speed_bar)


func _update_speedometer(car, speed_label, speed_bar) -> void:
	if not car or not is_instance_valid(car):
		return
		
	var kmh: int = 0
	if car.has_method("get_speed_kmh"):
		kmh = car.get_speed_kmh()

	if speed_label:
		speed_label.text = "%d" % kmh

	if speed_bar and speed_bar.get_parent():
		var ratio: float = clamp(float(kmh) / 100.0, 0.0, 1.0)
		var bg_width: float = speed_bar.get_parent().size.x
		speed_bar.size.x = bg_width * ratio


func _start_countdown() -> void:
	if player1:
		if "input_enable" in player1: player1.input_enable = false
		elif "input_enabled" in player1: player1.input_enabled = false
		else: player1.set_physics_process(false)
		
	if player2:
		if "input_enable" in player2: player2.input_enable = false
		elif "input_enabled" in player2: player2.input_enabled = false
		else: player2.set_physics_process(false)
	
	if countdown_label:
		countdown_label.show()
		
	for n in ["3", "2", "1"]:
		if countdown_label:
			countdown_label.text = n
			countdown_label.modulate = Color(1, 1, 1, 1)
		if beep_tick_sfx:
			beep_tick_sfx.play()
		await get_tree().create_timer(0.8).timeout
	
	if countdown_label:
		countdown_label.text = "Go!"
		countdown_label.modulate = Color(0.3, 1.0, 0.3, 1)
	if beep_go_sfx:
		beep_go_sfx.play()
		
	if player1:
		if "input_enable" in player1: player1.input_enable = true
		elif "input_enabled" in player1: player1.input_enabled = true
		else: player1.set_physics_process(true)
		
	if player2:
		if "input_enable" in player2: player2.input_enable = true
		elif "input_enabled" in player2: player2.input_enabled = true
		else: player2.set_physics_process(true)
	
	await get_tree().create_timer(0.6).timeout
	if countdown_label:
		countdown_label.hide()


func update_lap_ui() -> void:
	if label:
		label.text = "Lap: %d / %d" % [current_lap, max_laps]


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))


func _on_music_button_pressed() -> void:
	if music_player:
		if music_player.playing:
			music_player.stop()
			if music_button: music_button.text = "Play Music"
		else:
			music_player.play()
			if music_button: music_button.text = "Pause Music"


func _get_car(area: Area2D):
	if area is Car or area is Car2:
		return area
	elif area.get_parent() is Car or area.get_parent() is Car2:
		return area.get_parent()
	return null


func _on_track_collision_area_entered(area: Area2D) -> void:
	if area.has_method("hit_boundary"):
		area.hit_boundary()


# Finish Line Detection & Level Unlock Logic
func _on_start_line_area_entered(area: Area2D) -> void:
	if is_game_over or not can_trigger_start:
		return

	var car = _get_car(area)
	if not car:
		return

	# Require car to cross halfway checkpoint before awarding a new lap
	if "passed_halfway" in car and not car.passed_halfway:
		return

	car.passed_halfway = false

	if car == player1:
		p1_laps += 1
		current_lap = max(p1_laps, p2_laps)
		update_lap_ui()
		if p1_laps > max_laps:
			_complete_race("Player 1")

	elif car == player2:
		p2_laps += 1
		current_lap = max(p1_laps, p2_laps)
		update_lap_ui()
		if p2_laps > max_laps:
			_complete_race("Player 2")


# Checkpoint in the middle of the track to prevent backward shortcutting
func _on_halfway_checkpoint_area_entered(area: Area2D) -> void:
	var car = _get_car(area)
	if car and "passed_halfway" in car:
		car.passed_halfway = true


# Final completion trigger
func _complete_race(winner_name: String) -> void:
	is_game_over = true
	print("Race Finished! Winner: ", winner_name)

	if label:
		label.text = winner_name + " Wins!"

	# Unlocks Level 2 inside GameManager
	GameManager.unlock_next_level_if_earned(GameManager.current_level)

	# Transition to Level Select screen
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")


func _get_ui_node(paths: Array):
	for p in paths:
		if has_node(p):
			return get_node(p)
	return null
