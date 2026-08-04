extends Area2D

var lap: int = 0
const MAX_LAPS: int = 3

@onready var label = $CanvasLayer/Label

func _ready() -> void:
	if label:
		label.text = "Lap: %d / %d" % [lap, MAX_LAPS]
	
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var car = _get_car(area)
	
	if car != null:
		# Check if the player passed halfway
		if "passed_halfway" in car and car.passed_halfway:
			# --- LEGITIMATE LAP ---
			car.passed_halfway = false # Reset flag for next lap
			lap += 1
			
			if label:
				label.text = "Lap: %d / %d" % [lap, MAX_LAPS]
			print("Lap:", lap)
			
			if lap >= MAX_LAPS:
				print("Race Finished!!!!")
				get_tree().call_deferred("change_scene_to_file", "res://WinScene.tscn")
		else:
			# --- CHEAT DETECTED ---
			print("Cheat detected! Kicking to main menu...")
			
			# 1. Change text to red warning
			if label:
				label.text = "CHEAT DETECTED!\nKicking to Main Menu..."
				label.modulate = Color(1, 0, 0) # Turn text RED
			
			# 2. Pause for 1.5 seconds
			await get_tree().create_timer(1.5).timeout
			
			# 3. Kick to main menu
			get_tree().change_scene_to_file("res://main_menu.tscn")

func _get_car(area: Area2D):
	if area is Car:
		return area
	elif area.get_parent() is Car:
		return area.get_parent()
	return null
