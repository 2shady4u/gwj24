tool
extends TextureRect
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

onready var _upgrade_rect := $UpgradeRect
onready var _active_upgrade_rect := $ActiveUpgradeRect

signal slot_mouse_entered(class_upgrade)
signal slot_mouse_exited()

func _ready():
	var _error : int = connect("mouse_entered", self, "_on_mouse_entered")
	_error = connect("mouse_exited", self, "_on_mouse_exited")

func update_slot():
	if self.active_upgrade:
		_active_upgrade_rect.visible = true
		_active_upgrade_rect.texture = load(self.active_upgrade.grid_texture)
	else:
		_active_upgrade_rect.visible = false

	if self.upgrade:
		_upgrade_rect.visible = true
		_upgrade_rect.texture = load(self.upgrade.grid_texture)
	else:
		_upgrade_rect.visible = false

func _on_mouse_entered():
	emit_signal("slot_mouse_entered", self.upgrade)

func _on_mouse_exited():
	emit_signal("slot_mouse_exited")
