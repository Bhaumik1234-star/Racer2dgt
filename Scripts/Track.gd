extends Node

class_name Track

var total_checkpoints : int = 3  
var current_progress : int = 0

@onready var music_player = $CanvasLayer/MusicPlayer
@onready var music_button = $CanvasLayer/MusicButton

func _ready():
	_on_volume_slider_value_changed($CanvasLayer/VolumeSlider.value)   
	
func _on_music_button_pressed():
		if music_player.playing:
			music_player.stop()
			music_button.text = "Play Music"
		else:
			music_player.play()
			music_button.text = "Pause Music"

func _on_volume_slider_value_changed(value):
		if value == 0:
			music_player.volume_db = -80
		else:
			var db_volume = linear_to_db(value)
			music_player.volume_db = db_volume
		

func _on_track_collision_area_entered(area: Area2D) -> void:
	if area.has_method("hit_boundary"):
		area.hit_boundary()

func _on_start_line_area_entered(area: Area2D) -> void:
	if area is Car: 
		if current_progress == total_checkpoints:
			area.lap_completed() 
			current_progress = 0 
			print("Valid lap completed!")
		else:
			print("Lap ignored: Missed checkpoints.")

func _on_checkpoint_1_area_entered(area: Area2D) -> void:
	if area is Car:
		current_progress = 1
		print("Hit Checkpoint 1")

func _on_checkpoint_2_area_entered(area: Area2D) -> void:
	if area is Car:
		if current_progress == 1:
			current_progress = 2
			print("Hit Checkpoint 2")

func _on_checkpoint_3_area_entered(area: Area2D) -> void:
	if area is Car:
		if current_progress == 2:
			current_progress = 3
			print("Hit Checkpoint 3")
			
			
