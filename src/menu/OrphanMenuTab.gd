tool
extends class_menu_tab

onready var _back_button := $BackContainer/BackButton
onready var _grid_hbox := $VBoxContainer/HBoxContainer/GridVBox/GridHBox
onready var _grid_container := _grid_hbox.get_node("GridContainer")
onready var _available_vbox := _grid_hbox.get_node("VBoxContainer/ScrollContainer/AvailableVBox")

var _upgrade_button_resource := preload("res://src/menu/UpgradeButton.tscn")
var _upgrade_slot_resource := preload("res://src/menu/UpgradeSlot.tscn")

var _upgrade_slots := []
var _upgrade_buttons := []

export(int) var columns := 3 setget set_columns
func set_columns(value : int):
	columns = value
	if is_inside_tree():
		_grid_container = $VBoxContainer/HBoxContainer/GridVBox/GridHBox/GridContainer
		_grid_container.columns = value
		update_slots()

func _ready():
	var _error : int = _back_button.connect("pressed", self, "_on_back_button_pressed")

func update_tab():
	update_slots()
	update_buttons()

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

func update_buttons():
	_upgrade_buttons.clear()
	for child in _available_vbox.get_children():
		_available_vbox.remove_child(child)
		child.queue_free()

	print(State.upgrades)

	for upgrade in State.upgrades:
		var upgrade_button : class_upgrade_button = _upgrade_button_resource.instance()
		_available_vbox.add_child(upgrade_button)

		var _error : int = upgrade_button.connect("button_toggled", self, "_on_button_toggled")
		upgrade_button.upgrade = upgrade

		_upgrade_buttons.append(upgrade_button)

func _on_back_button_pressed():
	emit_signal("button_pressed", TABS.MISSION)
