extends Area2D

func _ready() -> void:
	# Listens for any Area2D entering this halfway line
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var car = _get_car(area)
	if car != null and car.has_method("on_hit_halfway"):
		car.on_hit_halfway()

func _get_car(area: Area2D):
	if area is Car or area is Car2:
		return area
	elif area.get_parent() is Car or area.get_parent() is Car2:
		return area.get_parent()
	return null
