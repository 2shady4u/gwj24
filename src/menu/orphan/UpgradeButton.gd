extends Button
class_name class_upgrade_button

var _upgrade_resource := preload("res://src/autoload/state/Upgrade.gd")

onready var _label := $HBoxContainer/Label

var upgrade : class_upgrade setget set_upgrade, get_upgrade
func set_upgrade(value : class_upgrade) -> void:
	_upgrade = weakref(value)

	_label.text = value.name
func get_upgrade() -> class_upgrade:
	return _upgrade.get_ref()

var _upgrade := WeakRef.new()

signal button_toggled()

func _ready():
	var _error := connect("pressed", self, "_on_button_pressed")

func reset_button(orphan_id : String):
	if self.upgrade.orphan_id.empty():
		pressed = false
		disabled = false
	else:
		pressed = true
		if self.upgrade.orphan_id == orphan_id:
			disabled = false
		else:
			disabled = true

func update_button(orphan_id : String, active_upgrade : class_upgrade):
	if disabled:
		return

	if self.upgrade == active_upgrade or self.upgrade.orphan_id == orphan_id:
		pressed = true
	else:
		pressed = false

func _on_button_pressed():
	emit_signal("button_toggled", pressed)
	release_focus()
