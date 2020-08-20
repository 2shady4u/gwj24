extends class_menu_tab

onready var _back_button := $BackContainer/BackButton
onready var _tab_container := $VBoxContainer/HBoxContainer/TabContainer
onready var _orphan_selection := $VBoxContainer/HBoxContainer2/VBoxContainer/ScrollContainer/OrphanSelection
onready var _available_vbox :=  $VBoxContainer/HBoxContainer/VBoxContainer/ScrollContainer/AvailableVBox

var _orphan_vbox_resource := preload("res://src/menu/orphanage/OrphanVBox.tscn")
var _orphan_tab_resource := preload("res://src/menu/orphanage/OrphanTab.tscn")
var _upgrade_button_resource := preload("res://src/menu/orphanage/UpgradeButton.tscn")

var _upgrade_buttons := []
var _orphan_vboxes := []

var _pressed_button : class_upgrade_button = null

func _ready():
	var _error : int = _back_button.connect("pressed", self, "_on_back_button_pressed")
	_error = connect("visibility_changed", self, "_on_visibility_changed")
	set_process_input(false)

func _on_visibility_changed():
	if visible:
		set_process_input(true)
	else:
		set_process_input(false)

func update_tab():
	update_orphans()
	update_upgrades()

func update_orphans():
	_orphan_vboxes.clear()
	for child in _tab_container.get_children():
		_tab_container.remove_child(child)
		child.queue_free()
	for child in _orphan_selection.get_children():
		_orphan_selection.remove_child(child)
		child.queue_free()

	for orphan in State.orphans:
		var orphan_tab : class_orphan_tab = _orphan_tab_resource.instance()
		_tab_container.add_child(orphan_tab)

		orphan_tab.orphan = orphan

		var orphan_vbox : class_orphan_vbox = _orphan_vbox_resource.instance()
		_orphan_selection.add_child(orphan_vbox)

		orphan_vbox.orphan = orphan
		orphan_vbox.activated = false

		_orphan_vboxes.append(orphan_vbox)

	set_current_orphan_tab(0)

func set_current_orphan_tab(index : int) -> void:
	for i in range(0, _orphan_vboxes.size()):
		if i == index:
			_orphan_vboxes[i].activated = true
		else:
			_orphan_vboxes[i].activated = false

	_tab_container.current_tab = index

func update_upgrades():
	_upgrade_buttons.clear()
	for child in _available_vbox.get_children():
		_available_vbox.remove_child(child)
		child.queue_free()

	for upgrade in State.upgrades:
		var upgrade_button : class_upgrade_button = _upgrade_button_resource.instance()
		_available_vbox.add_child(upgrade_button)

		var _error : int = upgrade_button.connect("button_toggled", self, "_on_button_toggled", [upgrade_button])
		upgrade_button.upgrade = upgrade

		_upgrade_buttons.append(upgrade_button)
	
	_upgrade_buttons[0].grab_focus()

func _on_button_toggled(pressed : bool, upgrade_button : class_upgrade_button):
	if _pressed_button:
		_pressed_button.pressed = false

	var tab = _tab_container.get_current_tab_control()
	var upgrade = upgrade_button.upgrade
	if pressed:
		tab.active_upgrade = upgrade
		tab.set_process_input(true)

		_pressed_button = upgrade_button
		set_process_input(false)
	else:
		tab.active_upgrade = null
		tab.set_process_input(false)

		_pressed_button = null
		set_process_input(true)

func reset_upgrade_button(upgrade : class_upgrade):
	for button in _upgrade_buttons:
		if button.upgrade == upgrade:
			button.pressed = false
			return

func _on_back_button_pressed():
	emit_signal("button_pressed", TABS.MISSION)

func _input(event):
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		var index : int = _tab_container.current_tab
		if event.is_action_pressed("move_left"):
			index -= 1
		if event.is_action_pressed("move_right"):
			index += 1

		index = wrapi(index, 0, _orphan_vboxes.size())
		set_current_orphan_tab(index)
