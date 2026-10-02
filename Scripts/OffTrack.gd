extends Area2D
# Slows down any vehicle that enters this area (e.g., grass, sand, or oil patches)

# Multiplier applied to vehicle speed when inside this zone (0.1 = 10% speed)
@export var slowdown := 0.1

func _ready() -> void:
	# Connect signals to detect when a vehicle enters or exits this area
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# Called when an Area2D enters this zone
func _on_area_entered(area: Area2D) -> void:
	# Apply speed penalty if the area belongs to Player 1 or Player 2
	if area is Car:
		area.speed_multiplier = slowdown
	if area is Car2:
		area.speed_multiplier = slowdown

# Called when an Area2D exits this zone
func _on_area_exited(area: Area2D) -> void:
	# Restore normal speed when leaving the area
	if area is Car:
		area.speed_multiplier = 1.0
	if area is Car2:
		area.speed_multiplier = 1.0
