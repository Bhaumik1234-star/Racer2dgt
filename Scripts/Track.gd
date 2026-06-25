extends Node

class_name Track

func _on_track_collision_area_entered(area: Area2D) -> void:
	if area.has_method("hit_boundary"):
		area.hit_boundary()


func _on_start_line_area_entered(area: Area2D) -> void:
	if area is Car: area.lap_completed()


 
