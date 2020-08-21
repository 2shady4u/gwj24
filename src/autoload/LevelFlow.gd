extends Node


signal current_character_changed(character)


var _current_character = null

var current_character : Character setget set_current_character, get_current_character
func set_current_character(value : Character) -> void:
	print("Setting current character")
	_current_character = value
	emit_signal("current_character_changed", _current_character)
func get_current_character() -> Character:
	return _current_character


func _ready():
	pass
	
func reload():
	current_character = null

