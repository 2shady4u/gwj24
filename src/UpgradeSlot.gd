tool
extends PanelContainer
class_name class_upgrade_slot

export(Vector2) var grid_position := Vector2.ZERO

var upgrade : class_upgrade setget set_upgrade, get_upgrade
func set_upgrade(value : class_upgrade) -> void:
	_upgrade = weakref(value)
	update_slot()
func get_upgrade() -> class_upgrade:
	return _upgrade.get_ref()

var active_upgrade : class_upgrade setget set_active_upgrade, get_active_upgrade
func set_active_upgrade(value : class_upgrade) -> void:
	_active_upgrade = weakref(value)
	update_slot()
func get_active_upgrade() -> class_upgrade:
	return _active_upgrade.get_ref()

var _upgrade := WeakRef.new()
var _active_upgrade := WeakRef.new()

signal slot_pressed(class_upgrade)

func update_slot():
	if self.active_upgrade:
		modulate = Color.lightblue
	elif self.upgrade:
		if self.active_upgrade:
			modulate = Color.lightblue
		else:
			modulate = self.upgrade.color
	else:
		modulate = Color.white

func _gui_input(event):
	if event.is_action_pressed("left_mouse_button"):
		if self.upgrade:
			emit_signal("slot_pressed", self.upgrade)
			self.active_upgrade = self.upgrade
