extends Node

var selected_vehicle: String = "car"
var stat_preset: String = "balanced"

var p1_color: Color = Color(1, 1, 1, 1)
var p2_color: Color = Color(1, 0.2, 0.2, 1)

var single_player: bool = false
var max_laps: int = 3
var master_volume: float = 1.0

var highest_unlocked_level: int = 1
var current_level: int = 1
var total_levels: int = 5

var pending_level_scene: String = ""

const SAVE_PATH: String = "user://game_save.cfg"

const PRESET_STATS := {
	"speed": {"max_speed_mult": 1.15, "grip_mult": 0.8, "accel_mult": 0.95},
	"balanced": {"max_speed_mult": 1.0, "grip_mult": 1.0, "accel_mult": 1.0},
	"handling": {"max_speed_mult": 0.9, "grip_mult": 1.3, "accel_mult": 1.05},
}


func _ready() -> void:
	load_game()


func unlock_next_level_if_earned(level_just_completed: int) -> void:
	if level_just_completed >= highest_unlocked_level and highest_unlocked_level < total_levels:
		highest_unlocked_level = level_just_completed + 1
		save_game()


func is_level_unlocked(level_number: int) -> bool:
	return level_number <= highest_unlocked_level


func get_preset_stats() -> Dictionary:
	return PRESET_STATS.get(stat_preset, PRESET_STATS["balanced"])


func apply_master_volume() -> void:
	var bus_idx := AudioServer.get_bus_index("Master")
	if bus_idx == -1:
		return
	if master_volume <= 0.0:
		AudioServer.set_bus_volume_db(bus_idx, -80.0)
	else:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(master_volume))


func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "highest_unlocked_level", highest_unlocked_level)
	config.set_value("settings", "master_volume", master_volume)
	config.save(SAVE_PATH)


func load_game() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err == OK:
		highest_unlocked_level = config.get_value("progress", "highest_unlocked_level", 1)
		master_volume = config.get_value("settings", "master_volume", 1.0)
		apply_master_volume()
