extends Area2D

class_name Car

# Top Speed of the car
@export var max_speed: float = 380.0

# How fast car slows down
@export var friction: float = 300.0

# How fast the car speeds up
@export var acceleration: float = 300

# How fast the car turns
@export var steer_strenght: float = 3.0

# Minimum turing power at high speed
@export var min_steer_factor: float = 0.5

@export var bounce_time: float = 0.2

@export var bounce_force: float = 10.0


# Player input
var _throttle: float = 0.0
var _steer: float = 0.0

# Start the car speed at 0
var _velocity: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Get input from players
	_throttle = Input.get_action_strength("ui_up")
	_steer = Input.get_axis("ui_left", "ui_right")
	


func _physics_process(delta: float) -> void:
	# Move car faster or slower
	apply_throttle(delta)
	# Turn the car
	apply_rotation(delta)
	# Move forward
	position += transform.x * _velocity * delta	
	
func apply_throttle(delta: float) -> void:
	if _throttle > 0.0:
		# Speed up
		_velocity += acceleration * delta
	else:
		# Slow down
		_velocity -= friction * delta
	# Keep speed bettwen 0 and max_speed
	_velocity = clampf(_velocity, 0.0, max_speed)
	
	
func get_steer_factor() -> float:
	# Make the steering senstivity lower when the car is moving faster
	return clampf(
		1.0 - pow(_velocity / max_speed, 2.0),
		min_steer_factor,
		1.0
	)
	
	
func apply_rotation(delta: float) -> void:
	# Turn the car left or right based on player input
	rotate(steer_strenght * delta * _steer)
	
func bounce() -> void:
	set_physics_process(false)
	_velocity = 0.0
	position += -transform.x * bounce_force
	await get_tree().create_timer(bounce_time).timeout
	set_physics_process(true)
	
func hit_boundary() -> void:
	bounce()
 
