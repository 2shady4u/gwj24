tool
extends HBoxContainer
class_name class_orphan_tab

onready var _grid_container := $GridVBox/GridContainer

var _upgrade_slot_resource := preload("res://src/menu/UpgradeSlot.tscn")

var _upgrade_slots := []

var orphan : class_orphan setget set_orphan, get_orphan
func set_orphan(value : class_orphan) -> void:
	_orphan = weakref(value)
	
	$VBoxContainer/BioHBox/VBoxContainer/HBoxContainer/NameLabel.text = value.name
	$VBoxContainer/BioHBox/VBoxContainer/BackStoryLabel.text = value.backstory

func get_orphan():
	return _orphan.get_ref()

export(int) var columns := 3 setget set_columns
func set_columns(value : int):
	columns = value
	if is_inside_tree():
		_grid_container = $GridVBox/GridContainer
		_grid_container.columns = value
		update_slots()

var _orphan := WeakRef.new()

func update_tab():
	pass

func update_slots():
	_upgrade_slots.clear()
	for child in _grid_container.get_children():
		_grid_container.remove_child(child)
		child.queue_free()

	for row_index in range(0, columns):
		for column_index in range(0, columns):
			var slot = _upgrade_slot_resource.instance()
			_grid_container.add_child(slot)
			slot.owner = self

			var _error : int = slot.connect("slot_pressed", self, "_on_slot_pressed")
			slot.grid_position = Vector2(row_index, column_index)

			_upgrade_slots.append(slot)
