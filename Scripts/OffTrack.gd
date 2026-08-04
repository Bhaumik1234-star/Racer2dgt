extends Area2D

@export var slowdown := 0.1

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	if area is Car:
		area.speed_multiplier = slowdown

func _on_area_exited(area: Area2D) -> void:
	if area is Car:
		area.speed_multiplier = 1.0
