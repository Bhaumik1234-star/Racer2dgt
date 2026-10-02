extends Node

# Stores global game settings and player progress across all scenes
var selected_vehicle: String = "car"
var pending_level_scene: String = ""
var highest_unlocked_level: int = 1
var current_level: int = 1
var single_player: bool = true
var max_laps: int = 1
var master_volume: float = 1.0

# File path where saved data is stored on the device
const SAVE_PATH := "user://game_save.cfg"

func _ready() -> void:
	# Load saved data as soon as the game starts
	load_game()

# Saves current level progress and settings to a file
func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "highest_unlocked_level", highest_unlocked_level)
	config.set_value("settings", "master_volume", master_volume)
	config.set_value("settings", "selected_vehicle", selected_vehicle)
	
	var err := config.save(SAVE_PATH)
	if err == OK:
		print("[SAVE SUCCESS] File updated on disk. Highest level: ", highest_unlocked_level)

# Loads progress and settings from the save file
func load_game() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err == OK:
		highest_unlocked_level = config.get_value("progress", "highest_unlocked_level", 1)
		master_volume = config.get_value("settings", "master_volume", 1.0)
		selected_vehicle = config.get_value("settings", "selected_vehicle", "car")
		apply_master_volume()

# Updates Godot's audio system volume using the master volume value
func apply_master_volume() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
