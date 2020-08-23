extends VBoxContainer
class_name class_perk_vbox

onready var _name_label := $HBoxContainer/NameLabel
onready var _description_label := $DescriptionLabel

var text : String setget set_text, get_text
func set_text(value: String):
	_name_label.text = value
func get_text() -> String:
	return _name_label.text

var description : String setget set_description, get_description
func set_description(value: String):
	_description_label.text = value
func get_description() -> String:
	return _description_label.text
