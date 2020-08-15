tool
extends Control

var _upgrade_button_resource := preload("res://src/UpgradeButton.tscn")
var _upgrade_slot_resource := preload("res://src/UpgradeSlot.tscn")

var _upgrade_slots := []
var _upgrade_buttons := []

onready var _grid_container := $HBox/Margin/VBox/GridVBox/GridContainer
onready var _active_upgrade_label := $HBox/Margin/VBox/ActiveUpgradeLabel
onready var _cumulative_effects := $HBox/Margin/VBox/CumulativeEffects

var active_upgrade : class_upgrade setget set_active_upgrade, get_active_upgrade
func set_active_upgrade(value : class_upgrade) -> void:
	_active_upgrade = weakref(value)
	update_active_upgrade_label()
func get_active_upgrade() -> class_upgrade:
	return _active_upgrade.get_ref()

var _active_upgrade := WeakRef.new()

export(int) var columns := 3 setget set_columns
func set_columns(value : int):
	columns = value
	if is_inside_tree():
		$HBox/Margin/VBox/GridVBox/GridContainer.columns = value
		create_slots()

func _ready():
	create_slots()
	create_buttons()

func create_slots():
	_upgrade_slots.clear()
	for child in $HBox/Margin/VBox/GridVBox/GridContainer.get_children():
		$HBox/Margin/VBox/GridVBox/GridContainer.remove_child(child)
		child.queue_free()

	for row_index in range(0, columns):
		for column_index in range(0, columns):
			var slot = _upgrade_slot_resource.instance()
			$HBox/Margin/VBox/GridVBox/GridContainer.add_child(slot)
			slot.owner = self

			var _error : int = slot.connect("slot_pressed", self, "_on_slot_pressed")

			slot.grid_position = Vector2(row_index, column_index)

			_upgrade_slots.append(slot)

func create_buttons():
	_upgrade_buttons.clear()
	for child in $HBox/InventoryScroll/VBoxContainer.get_children():
		remove_child(child)
		child.queue_free()

	for key in upgrades_dict.keys():
		var upgrade_button : class_upgrade_button = _upgrade_button_resource.instance()
		$HBox/InventoryScroll/VBoxContainer.add_child(upgrade_button)

		var _error : int = upgrade_button.connect("button_toggled", self, "_on_button_toggled")
		upgrade_button.create_upgrade(key, upgrades_dict[key])

		_upgrade_buttons.append(upgrade_button)

func update_active_upgrade_label():
	var text := "Active upgrade: "
	if self.active_upgrade:
		text += self.active_upgrade.id
	else:
		text += "NULL"
	_active_upgrade_label.text = text

func _on_slot_pressed(pressed_upgrade : class_upgrade):
	if pressed_upgrade:
		for slot in _upgrade_slots:
			if slot.upgrade == pressed_upgrade:
				slot.active_upgrade = pressed_upgrade
				slot.upgrade = null
			else:
				slot.active_upgrade = null
		self.active_upgrade = pressed_upgrade

func _on_button_toggled(pressed_upgrade : class_upgrade, button_pressed : bool):
	if pressed_upgrade:
		if self.active_upgrade:
			reset_upgrade_button(self.active_upgrade)

		if button_pressed:
			for slot in _upgrade_slots:
				if slot.grid_position in pressed_upgrade.grid_positions:
					slot.active_upgrade = pressed_upgrade
				else:
					slot.active_upgrade = null
			self.active_upgrade = pressed_upgrade
		else:
			for slot in _upgrade_slots:
				if slot.upgrade == pressed_upgrade:
					slot.upgrade = null
				slot.active_upgrade = null
			_cumulative_effects.remove_effects(pressed_upgrade)
			self.active_upgrade = null

func reset_upgrade_button(upgrade : class_upgrade):
	for button in _upgrade_buttons:
		if button.upgrade == upgrade:
			button.pressed = false
			return

func _input(event : InputEvent):
	if self.active_upgrade:
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
			self.active_upgrade.move(movement_direction, columns)
			for slot in _upgrade_slots:
				if slot.grid_position in self.active_upgrade.grid_positions:
					slot.active_upgrade = self.active_upgrade
				else:
					slot.active_upgrade = null
	
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
			_cumulative_effects.add_effects(self.active_upgrade)
			self.active_upgrade = null

var upgrades_dict := {
	"more_hp": {
		"text": "PLASMA BOOSTER",
		"effects": {
			"hp": 20
		},
		"grid": [
			[1,0],
			[1,1]
			],
		"color": Color.red
		},
	"faster_speed_but_decreased_health": {
		"text": "OVERLOAD CHIP",
		"effects": {
			"hp": -5,
			"speed": 20
		},
		"grid": [
			[1],
			[1],
			[1]
		],
		"color": Color.blue
	}
}
