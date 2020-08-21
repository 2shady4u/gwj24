extends Control


onready var turn_info = $TurnInfo
onready var name_label = $MarginContainer/HBoxContainer/VBoxContainer/NameLabel

var current_character: Character = null


func _ready():
	LevelFlow.connect("current_character_changed", self, "_on_current_character_changed")
	
func _on_current_character_changed(new_character: Character):
	print("Current character changed!")
	current_character = new_character
	turn_info.load_character(current_character)
	
	
	if current_character.team == "PLAYER":
		var character_name = Flow.get_orphan_value(current_character.type, "name", "None")
		name_label.text = character_name
	elif current_character.team == "ENEMY":
		var character_name = Flow.get_enemy_value(current_character.type, "name", "None")
		name_label.text = character_name
	

