extends Area2D

const MAX_LAPS: int = 3

# Generic per-racer lap tracking so this isn't hardcoded to just p1/p2.
var laps: Dictionary = {}   # car (Node) -> int lap count
var _order: Array = []      # display order (first car seen = P1, etc.)
var race_finished: bool = false

@onready var label = $CanvasLayer/Panel/Label if has_node("CanvasLayer/Panel/Label") else null
@onready var lap_sfx: AudioStreamPlayer = $LapChimeSFX if has_node("LapChimeSFX") else null
@onready var win_sfx: AudioStreamPlayer = $WinFanfareSFX if has_node("WinFanfareSFX") else null

func _ready() -> void:
	update_label()


func _register(car: Node) -> void:
	if not laps.has(car):
		laps[car] = 0
		_order.append(car)


func _display_name(car: Node) -> String:
	if "player_prefix" in car:
		if car.player_prefix == "p1":
			return "P1"
		elif car.player_prefix == "p2":
			return "P2"
	return "Racer"


func update_label() -> void:
	if not label:
		return
	# Sort by lap count (then finish order) to show current standings.
	var ranked = _order.duplicate()
	ranked.sort_custom(func(a, b): return laps.get(a, 0) > laps.get(b, 0))
	var parts: Array = []
	for car in ranked:
		if not is_instance_valid(car):
			continue
		parts.append("%s: %d/%d" % [_display_name(car), laps.get(car, 0), MAX_LAPS])
	label.text = " | ".join(parts)


func _on_area_entered(area: Area2D) -> void:
	if race_finished:
		return

	var car = _get_car(area)

	if car != null:
		_register(car)
		if car.passed_halfway:
			# --- LEGITIMATE LAP ---
			car.passed_halfway = false
			laps[car] = laps.get(car, 0) + 1

			update_label()

			print(_display_name(car), " Lap: ", laps[car])

			if laps[car] >= MAX_LAPS:
				race_finished = true
				print(_display_name(car), " wins the race!")
				if label:
					label.text = "%s WINS!" % _display_name(car)
				if win_sfx:
					win_sfx.play()
				await get_tree().create_timer(1.4).timeout
				get_tree().change_scene_to_file("res://WinScene.tscn")
			else:
				if lap_sfx:
					lap_sfx.play()
		else:
			# --- CHEAT DETECTED ---
			print("Cheat detected for ", _display_name(car), "! Kicking to main menu...")

			if label:
				label.text = "CHEAT DETECTED!\nKicking to Main Menu..."
				label.modulate = Color(1, 0, 0)

			await get_tree().create_timer(1.5).timeout
			get_tree().change_scene_to_file("res://main_menu.tscn")


func _get_car(area: Area2D):
	if area is Car or area is Car2:
		return area
	elif area.get_parent() is Car or area.get_parent() is Car2:
		return area.get_parent()
	return null
