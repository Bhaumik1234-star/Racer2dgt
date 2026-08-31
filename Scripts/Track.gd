extends Node
class_name Track

var total_checkpoints: int = 3
var current_progress: int = 0

var max_laps: int = 3
var current_lap: int = 1
var is_game_over: bool = false

var can_trigger_start: bool = true

@onready var music_player = $CanvasLayer/MusicPlayer if has_node("CanvasLayer/MusicPlayer") else null
@onready var music_button = $CanvasLayer/MusicButton if has_node("CanvasLayer/MusicButton") else null
@onready var label = $CanvasLayer/Label if has_node("CanvasLayer/Label") else null
@onready var volume_slider = $CanvasLayer/VolumeSlider if has_node("CanvasLayer/VolumeSlider") else null

@onready var countdown_label = $CanvasLayer/CountdownLabel if has_node("CanvasLayer/CountdownLabel") else null
@onready var beep_tick_sfx = $CanvasLayer/BeepTickSFX if has_node("CanvasLayer/BeepTickSFX") else null
@onready var beep_go_sfx = $CanvasLayer/BeepGoSFX if has_node("CanvasLayer/BeepGoSFX") else null

@onready var player1 = $Background/Player1 if has_node("Background/Player1") else null
@onready var player2 = $Background/Player2 if has_node("Background/Player2") else null


func _ready() -> void:
	if volume_slider:
		_on_volume_slider_value_changed(volume_slider.value)

	update_lap_ui()
	_start_countdown()


func _start_countdown() -> void:
	if player1: player1.input_enabled = false
	if player2: player2.input_enabled = false

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
		countdown_label.text = "GO!"
		countdown_label.modulate = Color(0.3, 1.0, 0.3, 1)
	if beep_go_sfx:
		beep_go_sfx.play()

	if player1: player1.input_enabled = true
	if player2: player2.input_enabled = true

	await get_tree().create_timer(0.6).timeout
	if countdown_label:
		countdown_label.hide()


func update_lap_ui() -> void:
	if label:
		label.text = "Current Lap: %d / %d" % [current_lap, max_laps]

func _on_music_button_pressed() -> void:
	if music_player:
		if music_player.playing:
			music_player.stop()
			if music_button: music_button.text = "Play Music"
		else:
			music_player.play()
			if music_button: music_button.text = "Pause Music"

func _on_volume_slider_value_changed(value: float) -> void:
	if music_player:
		if value == 0:
			music_player.volume_db = -80
		else:
			music_player.volume_db = linear_to_db(value)

func _get_car(area: Area2D):
	if area is Car or area is Car2:
		return area
	elif area.get_parent() is Car or area.get_parent() is Car2:
		return area.get_parent()
	return null

func _on_track_collision_area_entered(area: Area2D) -> void:
	if area.has_method("hit_boundary"):
		area.hit_boundary()

func _on_start_line_area_entered(_area: Area2D) -> void:
	if is_game_over or not can_trigger_start:
		return
