extends Node

class_name Track

var total_checkpoints : int = 3  
var current_progress : int = 0   

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
