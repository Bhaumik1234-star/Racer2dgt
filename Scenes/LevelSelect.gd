extends Control

# Levels are numbered 1-5 for display/progression purpose; the "scene"
# paths is whichever generated track files backs that slot.

const LEVELS := [
	{"num": 1, "name": "Sakura Circuit", "sub": "Japan • Technical", "scene": "res://Scenes/Track.tscn", "thumb": "res://Maps/Thumbs/Level1.png"},
	{"num": 2, "name": "Daytona Oval", "sub": "USA-style • Fast & Simple", "scene": "res://Scenes/Track_Level2.tscn", "thumb": "res://Maps/Thumbs/Level2.png"},
	{"num": 3, "name": "Sahara Chicane", "sub": "Desert • S-Curves", "scene": "res://Scenes/Track_Level3.tscn", "thumb": "res://Maps/Thumbs/Level3.png"},
	{"num": 4, "name": "Tokoyo Night Circuit", "sub": "Neon • Tight", "scene": "res://Scenes/Track_Level7.tscn", "thumb": "res://Maps/Thumbs/Level7.png"},
	{"num": 5, "name": "Nürburgring Final", "sub": "Hardest • 4 Chicanes", "scene": "res://Scenes/Track_Level10.tscn", "thumb": "res://Maps/Thumbs/Level10.png"},
]

@onready var grid: GridContainer = $VBoxContainer/ScrollContainer/GridContainer
@onready var click_sfx: AudioStreamPlayer = $ClickSFX if has_node("ClickSFX") else null
@onready var locked_label: Label = $VBoxContainer/LockedMsg if has_node("VBoxContainer/LockedMsg") else null

func _ready() -> void:
	if locked_label:
		locked_label.visible = false
		
	# Clear any old/editor children before building cards
	for child in grid.get_children():
		child.queue_free()
		
	for lvl in LEVELS:
		grid.add_child(_build_card(lvl))


func _build_card(lvl: Dictionary) -> Control:
	var is_locked: bool = lvl["num"] > GameManager.highest_unlocked_level
	
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(220, 210)
	
	var style := StyleBoxFlat.new()
	if is_locked:
		style.bg_color = Color(0.08, 0.08, 0.09, 0.85)
		style.border_color = Color(0.4, 0.4, 0.42, 0.6)
	else:
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
	
	var tex := TextureRect.new()
	if ResourceLoader.exists(lvl["thumb"]):
		tex.texture = load(lvl["thumb"])
	tex.custom_minimum_size = Vector2(196, 120)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	if is_locked:
		tex.modulate = Color(0.4, 0.4, 0.4, 1)
	vbox.add_child(tex)
	
	var num_label := Label.new()
	num_label.text = "LEVEL %d" % lvl["num"]
	num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num_label.add_theme_font_size_override("font_size", 13)
	num_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1) if is_locked else Color(1.0, 0.75, 0.2, 1))
	vbox.add_child(num_label)
	
	var name_label := Label.new()
	name_label.text = ("🔒 " + lvl["name"]) if is_locked else lvl["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	if is_locked:
		name_label.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55, 1))
	vbox.add_child(name_label)
	
	var sub_label := Label.new()
	sub_label.text = ("Beat Level %d to unlock" % (lvl["num"] - 1)) if is_locked else lvl["sub"]
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_label.add_theme_font_size_override("font_size", 12)
	sub_label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.4, 1) if is_locked else Color(0.75, 0.75, 0.8, 1))
	vbox.add_child(sub_label)
	
	var btn := Button.new()
	btn.flat = true
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.pressed.connect(func(): _on_level_pressed(lvl, is_locked))
	card.add_child(btn)
	
	return card


func _on_level_pressed(lvl: Dictionary, is_locked: bool) -> void:
	if click_sfx:
		click_sfx.play()

	if is_locked:
		if locked_label:
			locked_label.text = "Beat Level %d first to unlock this track!" % (lvl["num"] - 1)
			locked_label.visible = true
		return

	GameManager.current_level = lvl["num"]
	GameManager.pending_level_scene = lvl["scene"]
	get_tree().change_scene_to_file("res://Scenes/Tutorial.tscn")


func _on_back_button_pressed() -> void:
	if click_sfx:
		click_sfx.play()
	get_tree().change_scene_to_file("res://main_menu.tscn")
