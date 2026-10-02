extends Control
# Manages the level selection menu, dynamically building track cards and handling scene navigation

# List of all available track levels and their details
const LEVELS := [
	{"num": 1, "name": "Sakura Circuit", "sub": "Japan • Technical", "scene": "res://Scenes/Track.tscn", "thumb": "res://Maps/Thumbs/level1.png"},
	{"num": 2, "name": "Daytona Oval", "sub": "USA-style • Fast & Simple", "scene": "res://Scenes/Track_Level2.tscn", "thumb": "res://Maps/Thumbs/level2.png"},
	{"num": 3, "name": "Sahara Chicane", "sub": "Desert • S-Curves", "scene": "res://Scenes/Track_Level3.tscn", "thumb": "res://Maps/Thumbs/level3.png"},
]

# UI Node References
@onready var grid: GridContainer = $VBoxContainer/ScrollContainer/GridContainer
@onready var click_sfx: AudioStreamPlayer = $ClickSFX if has_node("ClickSFX") else null
@onready var locked_label: Label = $VBoxContainer/LockedMsg if has_node("VBoxContainer/LockedMsg") else null
@onready var back_button: Button = $BackButton if has_node("BackButton") else null

func _ready() -> void:
	# Hide lock message initially
	if locked_label:
		locked_label.visible = false
	
	# Connect back button signal if it isn't already connected
	if back_button and not back_button.pressed.is_connected(_on_back_button_pressed):
		back_button.pressed.connect(_on_back_button_pressed)

	# Clear old nodes and generate card UI
	if grid:
		for child in grid.get_children():
			child.queue_free()

		for lvl in LEVELS:
			grid.add_child(_build_card(lvl))


# Programmatically creates a UI card panel for a level
func _build_card(lvl: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(220, 210)
	
	# Active yellow border style for all unlocked tracks
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.14, 0.85)
	style.border_color = Color(1.0, 0.75, 0.2, 0.7)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	card.add_theme_stylebox_override("panel", style)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)
	
	# Add track thumbnail image
	var tex := TextureRect.new()
	if ResourceLoader.exists(lvl["thumb"]):
		tex.texture = load(lvl["thumb"])
	tex.custom_minimum_size = Vector2(196, 120)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	vbox.add_child(tex)
	
	# Add level number label
	var num_label := Label.new()
	num_label.text = "LEVEL %d" % lvl["num"]
	num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num_label.add_theme_font_size_override("font_size", 13)
	num_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.2, 1))
	vbox.add_child(num_label)
	
	# Add level title label
	var name_label := Label.new()
	name_label.text = lvl["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)
	
	# Add level subtitle description
	var sub_label := Label.new()
	sub_label.text = lvl["sub"]
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_label.add_theme_font_size_override("font_size", 12)
	sub_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8, 1))
	vbox.add_child(sub_label)
	
	# Add an invisible click button overlay across the whole card
	var btn := Button.new()
	btn.flat = true
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.pressed.connect(func(): _on_level_pressed(lvl))
	card.add_child(btn)
	
	return card

# Called when a level card is clicked
func _on_level_pressed(lvl: Dictionary) -> void:
	if click_sfx:
		click_sfx.play()
	
	# Store chosen level in global GameManager
	GameManager.current_level = lvl["num"]
	GameManager.pending_level_scene = lvl["scene"]
	
	# Load tutorial first if it exists, otherwise go straight to the track
	if ResourceLoader.exists("res://Scenes/Tutorial.tscn"):
		get_tree().change_scene_to_file("res://Scenes/Tutorial.tscn")
	else:
		get_tree().change_scene_to_file(lvl["scene"])

# Returns player to the main menu screen
func _on_back_button_pressed() -> void:
	if click_sfx:
		click_sfx.play()
	
	if ResourceLoader.exists("res://Scenes/main_menu.tscn"):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	elif ResourceLoader.exists("res://Scenes/MainMenu.tscn"):
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
