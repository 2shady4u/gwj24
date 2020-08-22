extends VBoxContainer
class_name class_orphan_vbox

onready var _name_label := $NameLabel
onready var _icon_rect := $IconRect

onready var _indicator_rect := $Indicator/TextureRect

var text : String setget set_text, get_text
func set_text(value: String):
	_name_label.text = value
func get_text() -> String:
	return _name_label.text

var texture : Texture setget set_texture, get_texture
func set_texture(value: Texture):
	_icon_rect.texture = value
func get_texture() -> Texture:
	return _icon_rect.texture

var activated := false setget set_activated
func set_activated(value : bool):
	activated = value
	_indicator_rect.visible = value
