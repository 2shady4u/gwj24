extends Node



signal current_character_changed(character)

var game_over_UI : Control = null
var text_overlay_UI : Control = null
var dialogue_overlay_UI : Control = null

var current_mission_packed_scene_path: String = ""

var _current_character = null
var _current_mission = null

var current_character : Character setget set_current_character, get_current_character
func set_current_character(value : Character) -> void:
	print("Setting current character")
	_current_character = value
	emit_signal("current_character_changed", _current_character)
func get_current_character() -> Character:
	return _current_character


var current_mission : Mission setget set_current_mission, get_current_mission
func set_current_mission(value : Mission) -> void:
	print("Setting current mission")
	_current_mission = value

func get_current_mission() -> Mission:
	return _current_mission


func _ready():
	pass
	
func reload():
	current_character = null

