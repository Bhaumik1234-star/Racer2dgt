extends Area2D

var lap = 0
const MAX_LAPS = 3

@onready var label = $CanvasLayer/Label

func  _ready():
	label.text = "Lap: %d / %d" % [lap, MAX_LAPS]
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area):
	if area is Car and lap < MAX_LAPS:
		lap += 1
		label.text = "Lap: %d / %d" % [lap, MAX_LAPS]
		print("Lap:", lap)
		
		if lap == MAX_LAPS:
			print("Race Finished!!!!")
