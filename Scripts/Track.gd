extends Node

class_name Track

var total_checkpoints: int = 3
var current_progress: int = 0

var max_laps: int = 3
var current_lap: int = 1
var is_game_over: bool = false

# Cooldown to prevent double-triggering from multiple Area2Ds on the same car
var can_trigger_start: bool = true

@onready var music_player = $CanvasLayer/MusicPlayer
@onready var music_button = $CanvasLayer/MusicButton
@onready var label = $CanvasLayer/Label
@onready var volume_slider = $CanvasLayer/VolumeSlider

func _ready() -> void:
	if volume_slider:
		_on_volume_slider_value_changed(volume_slider.value)

	update_lap_ui()
	print("Track ready.")

func update_lap_ui() -> void:
	if label:
		label.text = "Current Lap: %d / %d" % [current_lap, max_laps]

func _on_music_button_pressed() -> void:
	if music_player.playing:
		music_player.stop()
		music_button.text = "Play Music"
	else:
		music_player.play()
		music_button.text = "Pause Music"

func _on_volume_slider_value_changed(value: float) -> void:
	if value == 0:
		music_player.volume_db = -80
	else:
		music_player.volume_db = linear_to_db(value)

func _get_car(area: Area2D) -> Car:
	if area is Car:
		return area
	elif area.get_parent() is Car:
		return area.get_parent()
	return null

func _on_track_collision_area_entered(area: Area2D) -> void:
	if area.has_method("hit_boundary"):
		area.hit_boundary()

func _on_start_line_area_entered(area: Area2D) -> void:
	if is_game_over or not can_trigger_start:
		return

	var car = _get_car(area)
	if car:
		# Check if player hit all checkpoints before crossing start line
		if current_progress == total_checkpoints:
			current_progress = 0
			
			# If we just completed our final lap (Lap 3), end the game!
			if current_lap >= max_laps:
				print("3 Laps completed! Finishing game...")
				finish_game()
			else:
				current_lap += 1
				update_lap_ui()
				print("Lap completed! Now on Lap: ", current_lap)
				if car.has_method("lap_completed"):
					car.lap_completed()
				_start_cooldown()
		else:
			print("Start line crossed, but missed checkpoints. Current progress: %d/%d" % [current_progress, total_checkpoints])

func _start_cooldown() -> void:
	can_trigger_start = false
	await get_tree().create_timer(0.5).timeout
	can_trigger_start = true

func finish_game() -> void:
	is_game_over = true
	print("Race Finished!!!!")
	# Using call_deferred prevents physics collision errors when switching scenes
	get_tree().call_deferred("change_scene_to_file", "res://WinScene.tscn")

func _on_checkpoint_1_area_entered(area: Area2D) -> void:
	if is_game_over:
		return

	var car = _get_car(area)
	if car and current_progress == 0:
		current_progress = 1
		print("Checkpoint 1 reached.")

func _on_checkpoint_2_area_entered(area: Area2D) -> void:
	if is_game_over:
		return

	var car = _get_car(area)
	if car and current_progress == 1:
		current_progress = 2
		print("Checkpoint 2 reached.")

func _on_checkpoint_3_area_entered(area: Area2D) -> void:
	if is_game_over:
		return

	var car = _get_car(area)
	if car and current_progress == 2:
		current_progress = 3
		print("Checkpoint 3 reached.")
