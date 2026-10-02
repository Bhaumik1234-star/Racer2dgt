extends Area2D

# Detects when a vehicle crosses the halfway checkpoint on the track
func _ready() -> void:
	# Connect signal to detect when another Area2D enters this trigger
	area_entered.connect(_on_area_entered)

# Called whenever an Area2D enters this checkpoint
func _on_area_entered(area: Area2D) -> void:
	var car = _get_car(area)
	# Check if the object is a valid car and notify it that it passed halfway
	if car != null and car.has_method("on_hit_halfway"):
		car.on_hit_halfway()

# Helper function to find the car node (checks the area itself or its parent)
func _get_car(area: Area2D):
	if area is Car or area is Car2:
		return area
	elif area.get_parent() is Car or area.get_parent() is Car2:
		return area.get_parent()
	return null
