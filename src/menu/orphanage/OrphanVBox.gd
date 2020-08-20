extends VBoxContainer
class_name class_orphan_vbox

onready var _name_label := $NameLabel
onready var _indicator_rect := $Indicator/TextureRect

# DO NOT SAVE THE ORPHAN HERE!
var orphan : class_orphan setget set_orphan
func set_orphan(value: class_orphan):
	_name_label.text = value.name

var activated := false setget set_activated
func set_activated(value : bool):
	activated = value
	_indicator_rect.visible = value
