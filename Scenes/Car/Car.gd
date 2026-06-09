extends Area2D
class_name Car

@export var max_speed: float = 380.0
@export var friction: float = 300.0
@export var acceleration: float = 300.0
@export var steer_strength: float = 5.0
@export var min_steer_factor: float = 0.5

var _throttle: float = 0.0
var _steer: float = 0.0
var _velocity: float = 0.0

var spawn_position: Vector2
var spawn_rotation: float

func _ready() -> void:
	spawn_position = global_position
	spawn_rotation = rotation

func _process(_delta: float) -> void:
	_throttle = Input.get_action_strength("ui_up")
	_steer = Input.get_axis("ui_left", "ui_right")

func _physics_process(delta: float) -> void:
	apply_throttle(delta)
	apply_rotation(delta)
	position += transform.x * _velocity * delta

func apply_throttle(delta: float) -> void:
	if _throttle > 0.0:
		_velocity += acceleration * delta
	else:
		_velocity -= friction * delta

	_velocity = clampf(_velocity, 0.0, max_speed)

func get_steer_factor() -> float:
	return clampf(
		1.0 - pow(_velocity / max_speed, 2.0),
		min_steer_factor,
		1.0
	)

func apply_rotation(delta: float) -> void:
	rotate(steer_strength * delta * _steer * get_steer_factor())

func hit_boundary() -> void:
	_velocity = 0.0
	global_position = spawn_position
	rotation = spawn_rotation
