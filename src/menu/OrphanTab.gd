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

var active_upgrade : class_upgrade setget set_active_upgrade, get_active_upgrade
func set_active_upgrade(value : class_upgrade) -> void:
	# var old_upgrade = self.active_upgrade
	_active_upgrade = weakref(value)

	for slot in _upgrade_slots:
		if value:
			if slot.grid_position in value.grid_positions:
				slot.active_upgrade = value
			else:
				slot.active_upgrade = null
		else:
			slot.active_upgrade = null
	
func get_active_upgrade():
	return _active_upgrade.get_ref()

export(int) var columns := 3 setget set_columns
func set_columns(value : int):
	columns = value
	if is_inside_tree():
		_grid_container = $GridVBox/GridContainer
		_grid_container.columns = value
		update_slots()

var _orphan := WeakRef.new()
var _active_upgrade := WeakRef.new()

func _ready():
	update_slots()

func update_tab():
	update_slots()

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

func _input(event : InputEvent):
	var movement_direction := Vector2.ZERO
	if event.is_action_pressed("move_left"):
		movement_direction.y -= 1
	if event.is_action_pressed("move_right"):
		movement_direction.y += 1
	if event.is_action_pressed("move_up"):
		movement_direction.x -= 1
	if event.is_action_pressed("move_down"):
		movement_direction.x += 1

	if movement_direction != Vector2.ZERO:
		move_active_upgrade(movement_direction)
	
	if event.is_action_pressed("confirm"):
		# First check if it is possible to place the upgrade!!!
		for slot in _upgrade_slots:
			if slot.active_upgrade == self.active_upgrade:
				if slot.upgrade != null:
					return
		# If we didn't return...then everything is ok!
		for slot in _upgrade_slots:
			if slot.active_upgrade == self.active_upgrade:
				slot.upgrade = self.active_upgrade
				slot.active_upgrade = null
		self.active_upgrade = null

func move_active_upgrade(movement_direction : Vector2):
	var new_positions := []
	for slot in _upgrade_slots:
		if slot.active_upgrade == self.active_upgrade:
			var new_position = slot.grid_position
			new_position += movement_direction
			if new_position.x < 0 or new_position.x > columns-1:
				return
			if new_position.y < 0 or new_position.y > columns-1:
				return
			new_positions.append(new_position)

	for slot in _upgrade_slots:
		if slot.grid_position in new_positions:
			slot.active_upgrade = self.active_upgrade
		else:
			slot.active_upgrade = null
	
