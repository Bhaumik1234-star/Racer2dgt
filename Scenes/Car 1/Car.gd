extends Area2D
class_name Car

# Set "p1" for Player 1 and "p2" for Player 2 in the Inspector!
@export var player_prefix: String = "p1"

@export var max_speed: float = 480.0
@export var reverse_speed: float = 180.0
@export var acceleration: float = 400.0
@export var friction: float = 300.0
@export var steer_strength: float = 3.4
@export var min_steer_factor: float = 0.7

var _throttle: float = 0.0
var _steer: float = 0.0
var _velocity: float = 0.0
var speed_multiplier: float = 1.0

var spawn_position: Vector2
var spawn_rotation: float

# Variable to track halfway completion
var passed_halfway: bool = false


func _ready() -> void:
	spawn_position = global_position
	spawn_rotation = rotation

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	# Disable local cameras if they exist under this node
	if has_node("Cam_Default"): $Cam_Default.enabled = false
	if has_node("Cam_Chase"): $Cam_Chase.enabled = false
	if has_node("Cam_Close"): $Cam_Close.enabled = false
	if has_node("Cam_Tactical"): $Cam_Tactical.enabled = false


func _process(_delta: float) -> void:
	# Controls movement using player_prefix
	_throttle = Input.get_axis(player_prefix + "_down", player_prefix + "_up")
	_steer = Input.get_axis(player_prefix + "_left", player_prefix + "_right")


func _physics_process(delta: float) -> void:
	apply_throttle(delta)
	apply_rotation(delta)
	position += transform.x * _velocity * delta


# MOVEMENT
func apply_throttle(delta: float) -> void:
	if _throttle > 0:
		_velocity += acceleration * delta
	elif _throttle < 0:
		_velocity -= acceleration * delta
	else:
		_velocity = move_toward(_velocity, 0, friction * delta)

	_velocity = clamp(
		_velocity,
		-reverse_speed * speed_multiplier,
		max_speed * speed_multiplier
	)


# TURNING (no spinning in place)
func apply_rotation(delta: float) -> void:
	if abs(_velocity) > 10:
		rotate(
			steer_strength *
			delta *
			_steer *
			sign(_velocity)
		)


# RESET / AREAS
func hit_boundary() -> void:
	_velocity = 0.0
	global_position = spawn_position
	rotation = spawn_rotation


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("boundary"):
		hit_boundary()
	elif area.is_in_group("grass"):
		speed_multiplier = 0.4


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("grass"):
		speed_multiplier = 1.0


func lap_completed() -> void: 
	print("lap_completed")


# Called when the car touches the HALFWAY line
func on_hit_halfway() -> void:
	passed_halfway = true
	print("Halfway point passed! Finish line is now valid.")
