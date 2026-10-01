extends Camera2D

@export var car1: Node2D
@export var car2: Node2D

@export var min_zoom : float = 0.4
@export var max_zoom : float = 1.0
@export var margin: Vector2 = Vector2(400,400)
@export var follow_speed: float = 5.0

func _process(delta: float) -> void:
	# Check which cars are valid and active
	var has_car1: bool = is_instance_valid(car1) and car1.visible
	var has_car2: bool = is_instance_valid(car2) and car2.visible

	# If neither car exists, do nothing
	if not has_car1 and not has_car2:
		return

	var target_position: Vector2
	var target_zoom: float

	# 2-Player Mode: Both cars are present
	if has_car1 and has_car2:
		target_position = (car1.global_position + car2.global_position) * 0.5
		
		var rect = Rect2(car1.global_position, Vector2.ZERO)
		rect = rect.expand(car2.global_position)
		rect = rect.grow_individual(margin.x, margin.y, margin.x, margin.y)
		
		var screen_size = get_viewport_rect().size
		var zoom_x = screen_size.x / rect.size.x
		var zoom_y = screen_size.y / rect.size.y
		target_zoom = clamp(min(zoom_x, zoom_y), min_zoom, max_zoom)

	# 1-Player Mode (Player 1 only)
	elif has_car1:
		target_position = car1.global_position
		target_zoom = max_zoom

	# 1-Player Mode (Player 2 only)
	else:
		target_position = car2.global_position
		target_zoom = max_zoom

	# Smoothly update position and zoom
	global_position = global_position.lerp(target_position, follow_speed * delta)
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), follow_speed * delta)
