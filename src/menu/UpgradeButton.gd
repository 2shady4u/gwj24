extends Button
class_name class_upgrade_button

var _upgrade_resource := preload("res://src/autoload/state/Upgrade.gd")

var upgrade : class_upgrade setget set_upgrade, get_upgrade
func set_upgrade(value : class_upgrade) -> void:
	_upgrade = weakref(value)
	if value:
		$HBoxContainer/Label.text = value.name
func get_upgrade() -> class_upgrade:
	return _upgrade.get_ref()

var _upgrade := WeakRef.new()

signal button_toggled()

func _ready():
	var _eror := connect("toggled", self, "_on_button_toggled")

func _on_button_toggled(button_pressed : bool):
	emit_signal("button_toggled", button_pressed)
	release_focus()
