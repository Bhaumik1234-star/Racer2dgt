extends Control

const SECTIONS := [
	{"title": "PLAYER 1 CONTROLS", "body": "W \u2014 Accelerate\nS \u2014 Reverse / Brake\nA / D \u2014 Steer Left / Right"},
	{"title": "PLAYER 2 CONTROLS", "body": "\u2129 Up \u2014 Accelerate\n\u2193 Down \u2014 Reverse / Brake\n\u2190 / \u2192 \u2014 Steer Left / Right"},
	{"title": "Drift & Boost", "body": "Steer hard while at speed to drift around a corner. Hold the drift and release it to fire off a speed BOOST \u2014 the longer the drift, the bigger the boost."},
	{"title": "Bumping", "body": "Cars can knock each other around on contact. Use it to defend your line \u2014 or shove a rival off theirs."},
	{"title": "STAY ON THE ROAD", "body": "Driving onto the grass slows u down a lot. Watch your speedometer in the corner \u2014 it drops fast off-roads."},
	{"title": "LAPS & WINNING", "body": "First to complete all the laps wins the race. Beat a level to unlock the next one!"},
]

@onready var list: VBoxContainer = $VBoxContainer/ScrollContainer/SectionList
@onready var music_player: AudioStreamPlayer = $MusicPlayer if has_node("MusicPlayer") else null
@onready var click_sfx: AudioStreamPlayer = $ClickSFX if has_node("ClickSFX") else null

func _ready() -> void:
	for sections in SECTIONS:
		list.add_child(_build_section(section))

		
	if music_player:
		music_player.finished.connect(func(): music_player.play())
		music_player.play()
		
func _build_section(section: Dictionary) -> Control:
	var card := PanelContainer.new()
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.14, 0.85)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.border_width_left = 2
	style.border_width_top = 2 
	style.border_width_right = 2
	style.border_width_bottom = 2 
	style.border_color = Color(1.0, 0.75, 0.2, 0.6)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	card.add_theme_stylebox_override("panel", style)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)
	
	var title = Label.new()
	title.text = section["title"]
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.75, 0.2, 1))
	vbox.add_child(title)
	
	var body := Label.new()
	body.text = section["body"]
	body.add_theme_font_size_override("font_size", 16)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(body)
	
	return card
	

func _on_star_race_button_pressed() -> void:
	if click_sfx:
		click_sfx.play()
	if GameManager.pending_level_scene != "":
		get_tree().change_scene_to_file(GameManager.pending_level_scene)
	else:
		get_tree().change_scene_to_file("res://Scenes/LevelSelect.tscn")


func _on_back_button_pressed() -> void:
	if click_sfx:
		click_sfx.play()
	if GameManager.pending_level_scene != "":
		get_tree().change_scene_to_file("res://Scenes/LevelSelect.tscn")
	else:
		get_tree().change_scene_to_file("res://main_menu.tscn")
		
	
	

	
	
