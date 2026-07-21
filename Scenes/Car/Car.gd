extends Area2D
class_name Car

@export var max_speed: float = 380.0
@export var reverse_speed: float = 180.0
@export var acceleration: float = 300.0
@export var friction: float = 300.0
@export var steer_strength: float = 3.7
@export var min_steer_factor: float = 0.4

var _throttle: float = 0.0
var _steer: float = 0.0
var _velocity: float = 0.0
var speed_multiplier: float = 1.0

var spawn_position: Vector2
var spawn_rotation: float

# Cameras
@onready var cam_default: Camera2D = $Cam_Default
@onready var cam_chase: Camera2D = $Cam_Chase
@onready var cam_close: Camera2D = $Cam_Close
@onready var cam_tactical: Camera2D = $Cam_Tactical

var camera_index: int = 0


func _ready() -> void:
	spawn_position = global_position
	spawn_rotation = rotation

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	update_camera()


func _process(_delta: float) -> void:
	_throttle = Input.get_axis("ui_down", "ui_up")
	_steer = Input.get_axis("ui_left", "ui_right")

	if Input.is_action_just_pressed("change_camera"):
		camera_index += 1
		if camera_index > 3:
			camera_index = 0
		update_camera()


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


# CAMERA SWITCH
func update_camera() -> void:
	cam_default.enabled = false
	cam_chase.enabled = false
	cam_close.enabled = false
	cam_tactical.enabled = false

	match camera_index:
		0:
			cam_default.enabled = true
		1:
			cam_chase.enabled = true
		2:
			cam_close.enabled = true
		3:
			cam_tactical.enabled = true


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
		
