extends Area2D
class_name Car2

# Set to "p2" for Player 2 controls in Project Settings -> Input Map
@export var player_prefix: String = "p2"

@export var max_speed: float = 480.0
@export var reverse_speed: float = 180.0
@export var acceleration: float = 400.0
@export var friction: float = 300.0
@export var steer_strength: float = 3.4
@export var min_steer_factor: float = 0.7

## Grip: how quickly actual movement catches up to the direction the car is
## facing. Lower values = more drift/slide, higher = more "on rails".
@export var grip: float = 9.0
## Minimum time (seconds) holding a drift before releasing it gives a boost.
@export var min_drift_time: float = 0.35
## Angle (radians) between facing and movement direction that counts as drifting.
@export var drift_angle_threshold: float = 0.22
@export var boost_strength: float = 260.0
@export var boost_duration: float = 0.6

@export var bump_force: float = 320.0
@export var wall_bounce_loss: float = 0.45
@export var wall_pushback: float = 26.0

@export var car_texture: Texture2D
@export var bike_texture: Texture2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var drift_particles: GPUParticles2D = $DriftParticles if has_node("DriftParticles") else null

@onready var engine_sfx: AudioStreamPlayer2D = $EngineSFX if has_node("EngineSFX") else null
@onready var drift_sfx: AudioStreamPlayer2D = $DriftSFX if has_node("DriftSFX") else null
@onready var boost_sfx: AudioStreamPlayer2D = $BoostSFX if has_node("BoostSFX") else null
@onready var crash_sfx: AudioStreamPlayer2D = $CrashSFX if has_node("CrashSFX") else null

var _throttle: float = 0.0
var _steer: float = 0.0
var _velocity: float = 0.0
var speed_multiplier: float = 1.0
var input_enabled: bool = true

var move_velocity: Vector2 = Vector2.ZERO
var drift_time: float = 0.0
var is_drifting: bool = false
var boost_timer: float = 0.0
var boost_speed: float = 0.0

var spawn_position: Vector2
var spawn_rotation: float

# Flag used by the halfway line and finish line anti-cheat system
var passed_halfway: bool = false


func _ready() -> void:
	# Vehicle texture swap based on options selection
	if GameManager.selected_vehicle == "bike" and bike_texture:
		sprite.texture = bike_texture
	elif car_texture:
		sprite.texture = car_texture

	if GameManager.has_method("get_preset_stats"):
		var stats = GameManager.get_preset_stats()
		max_speed *= stats.get("max_speed_mult", 1.0)
		grip *= stats.get("grip_mult", 1.0)
		acceleration *= stats.get("accel_mult", 1.0)

	if "p2_color" in GameManager:
		sprite.modulate = GameManager.p2_color

	spawn_position = global_position
	spawn_rotation = rotation

	add_to_group("racers")

	# Connect collision signals for grass, boundaries, and other racers
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	# Disable internal camera nodes if present
	if has_node("Cam_Default"): $Cam_Default.enabled = false
	if has_node("Cam_Chase"): $Cam_Chase.enabled = false
	if has_node("Cam_Close"): $Cam_Close.enabled = false
	if has_node("Cam_Tactical"): $Cam_Tactical.enabled = false


func _process(_delta: float) -> void:
	if not input_enabled:
		_throttle = 0.0
		_steer = 0.0
		return
	_throttle = Input.get_axis(player_prefix + "_down", player_prefix + "_up")
	_steer = Input.get_axis(player_prefix + "_left", player_prefix + "_right")


func _physics_process(delta: float) -> void:
	apply_throttle(delta)
	apply_rotation(delta)
	_update_drift_and_move(delta)
	_update_engine_sfx()


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


func apply_rotation(delta: float) -> void:
	if abs(_velocity) > 10:
		rotate(
			steer_strength *
			delta *
			_steer *
			sign(_velocity)
		)


func _update_drift_and_move(delta: float) -> void:
	var forward: Vector2 = transform.x
	var target_velocity: Vector2 = forward * _velocity

	move_velocity = move_velocity.lerp(target_velocity, clamp(grip * delta, 0.0, 1.0))

	if move_velocity.length() > 40.0 and abs(_velocity) > max_speed * 0.35:
		var angle_diff = abs(move_velocity.normalized().angle_to(forward))
		if angle_diff > drift_angle_threshold:
			is_drifting = true
			drift_time += delta
		else:
			_end_drift()
	else:
		_end_drift()

	if drift_particles:
		drift_particles.emitting = is_drifting

	var extra := Vector2.ZERO
	if boost_timer > 0.0:
		boost_timer -= delta
		extra = forward * boost_speed

	position += (move_velocity + extra) * delta


func _end_drift() -> void:
	if is_drifting and drift_time >= min_drift_time:
		boost_timer = boost_duration
		boost_speed = boost_strength * clamp(drift_time / 1.2, 0.4, 1.8)
		if boost_sfx:
			boost_sfx.play()
	is_drifting = false
	drift_time = 0.0
	if drift_sfx and drift_sfx.playing:
		drift_sfx.stop()


func _update_engine_sfx() -> void:
	if not engine_sfx:
		return
	var speed_ratio: float = clamp(abs(_velocity) / max_speed, 0.0, 1.0)
	engine_sfx.pitch_scale = 0.75 + speed_ratio * 1.15
	engine_sfx.volume_db = lerp(-10.0, -3.0, speed_ratio)

	if drift_sfx:
		if is_drifting and not drift_sfx.playing:
			drift_sfx.play()
		elif not is_drifting and drift_sfx.playing:
			drift_sfx.stop()


func hit_boundary() -> void:
	var away: Vector2 = -move_velocity
	if away.length() < 1.0:
		away = -transform.x
	away = away.normalized()
	position += away * wall_pushback
	move_velocity = move_velocity * -wall_bounce_loss
	_velocity = -abs(_velocity) * wall_bounce_loss
	boost_timer = 0.0
	if crash_sfx:
		crash_sfx.play()


func _bump(other: Node2D) -> void:
	var away: Vector2 = global_position - other.global_position
	if away.length() < 1.0:
		away = Vector2(randf() - 0.5, randf() - 0.5)
	away = away.normalized()
	move_velocity += away * bump_force
	_velocity = move_velocity.length() * 0.4
	if crash_sfx:
		crash_sfx.play()

	if other.has_method("_receive_bump"):
		other._receive_bump(-away)


func _receive_bump(dir: Vector2) -> void:
	move_velocity += dir * bump_force


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("boundary"):
		hit_boundary()
	elif area.is_in_group("grass"):
		speed_multiplier = 0.4
	elif area.is_in_group("racers") and area != self:
		_bump(area)


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("grass"):
		speed_multiplier = 1.0


# Called when Player 2 passes through the finish line
func lap_completed() -> void:
	print("P2 Lap Completed!")


# Called when Player 2 passes through the halfway line
func on_hit_halfway() -> void:
	passed_halfway = true
	print("P2 Halfway point passed!")
