extends class_menu_tab

onready var _back_button := $BackContainer/BackButton
onready var _tab_container := $VBoxContainer/TopHBox/TabContainer
onready var _orphan_selection := $VBoxContainer/BottomHBox/VBoxContainer/ScrollContainer/OrphanSelection
onready var _available_vbox :=  $VBoxContainer/TopHBox/VBoxContainer/ScrollContainer/AvailableVBox

onready var _description_label := $VBoxContainer/BottomHBox/PanelContainer/DescriptionLabel

var _orphan_vbox_resource := preload("res://src/menu/orphan/OrphanVBox.tscn")
var _orphan_tab_resource := preload("res://src/menu/orphan/OrphanTab.tscn")
var _upgrade_button_resource := preload("res://src/menu/orphan/UpgradeButton.tscn")

var active_upgrade : class_upgrade setget set_active_upgrade, get_active_upgrade
func set_active_upgrade(value : class_upgrade) -> void:
	_active_upgrade = weakref(value)

	if value:
		_description_label.text = value.description
	else:
		_description_label.text = ""
func get_active_upgrade() -> class_upgrade:
	return _active_upgrade.get_ref()
var _active_upgrade := WeakRef.new()

func _ready():
	var _error : int = _back_button.connect("pressed", self, "_on_back_button_pressed")
	_error = connect("visibility_changed", self, "_on_visibility_changed")

	# Disable input initially!
	set_process_input(false)

func _on_visibility_changed():
	if visible:
		set_process_input(true)
	else:
		set_process_input(false)

func update_tab():
	clear_tab()

	# Just like in the state, the upgrades need to be updated first!!!!
	update_upgrades()
	update_orphans()

	AudioEngine.play_background_music("upgrid")

func clear_tab():
	# Related to orphans
	for child in _tab_container.get_children():
		_tab_container.remove_child(child)
		child.queue_free()
	for child in _orphan_selection.get_children():
		_orphan_selection.remove_child(child)
		child.queue_free()

	# Related to upgrades
	for child in _available_vbox.get_children():
		_available_vbox.remove_child(child)
		child.queue_free()

func update_orphans():
	for orphan in State.orphans:
		# Add orphan tab
		var orphan_tab : class_orphan_tab = _orphan_tab_resource.instance()
		_tab_container.add_child(orphan_tab)

		var _error : int = orphan_tab.connect("upgrade_placed", self, "_on_upgrade_placed", [orphan_tab])
		_error = orphan_tab.connect("upgrade_mouse_entered", self, "_on_upgrade_mouse_entered")
		_error = orphan_tab.connect("upgrade_mouse_exited", self, "_on_upgrade_mouse_exited")
		orphan_tab.orphan = orphan

		# Add orphan vbox
		var orphan_vbox : class_orphan_vbox = _orphan_vbox_resource.instance()
		_orphan_selection.add_child(orphan_vbox)

		orphan_vbox.text = orphan.name
		orphan_vbox.texture = load(orphan.icon_texture)
		orphan_vbox.activated = false

	set_current_orphan_tab(0)

func update_upgrades():
	for upgrade in State.upgrades:
		var upgrade_button : class_upgrade_button = _upgrade_button_resource.instance()
		_available_vbox.add_child(upgrade_button)

		var _error : int = upgrade_button.connect("button_toggled", self, "_on_button_pressed", [upgrade_button])
		_error = upgrade_button.connect("button_mouse_entered", self, "_on_upgrade_mouse_entered")
		_error = upgrade_button.connect("button_mouse_exited", self, "_on_upgrade_mouse_exited")
		upgrade_button.upgrade = upgrade

	if _available_vbox.get_child_count() > 0:
		_available_vbox.get_children()[0].grab_focus()

func _on_upgrade_placed(orphan_tab : class_orphan_tab):
	AudioEngine.play_effect("ui_chip_in")
	orphan_tab.active_upgrade = null
	orphan_tab.set_process_input(false)

	self.active_upgrade = null
	set_process_input(true)

func _on_button_pressed(pressed : bool, upgrade_button : class_upgrade_button):
	var orphan_tab : class_orphan_tab = _tab_container.get_current_tab_control()
	var orphan : class_orphan = orphan_tab.orphan
	var upgrade = upgrade_button.upgrade

	if pressed:
		orphan_tab.active_upgrade = upgrade
		orphan_tab.set_process_input(true)

		self.active_upgrade = upgrade
		set_process_input(false)
	else:
		orphan_tab.active_upgrade = null
		orphan_tab.set_process_input(false)

		self.active_upgrade = null
		set_process_input(true)

		orphan_tab.remove_upgrade_from_grid(upgrade)

	# Update the buttons as well!!
	for button in _available_vbox.get_children():
		button.update_button(orphan.id, self.active_upgrade)

func _on_upgrade_mouse_entered(upgrade : class_upgrade):
	if upgrade:
		_description_label.text = upgrade.description
	else:
		_description_label.text = ""

func _on_upgrade_mouse_exited():
	_description_label.text = ""

func _on_back_button_pressed():
	AudioEngine.play_effect("ui_back")
	emit_signal("button_pressed", TABS.MISSION)

func _on_button_mouse_entered():
	AudioEngine.play_effect("ui_move")

func _input(event):
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		var index : int = _tab_container.current_tab
		if event.is_action_pressed("move_left"):
			AudioEngine.play_effect("ui_move")
			index -= 1
		if event.is_action_pressed("move_right"):
			AudioEngine.play_effect("ui_move")
			index += 1

		index = wrapi(index, 0, _tab_container.get_tab_count())
		set_current_orphan_tab(index)

func set_current_orphan_tab(index : int) -> void:
	var orphan_vboxes := _orphan_selection.get_children()
	for i in range(0, orphan_vboxes.size()):
		if i == index:
			orphan_vboxes[i].activated = true
		else:
			orphan_vboxes[i].activated = false

	_tab_container.current_tab = index
	var orphan_tab : class_orphan_tab = _tab_container.get_current_tab_control()
	var orphan_id : String = orphan_tab.orphan.id

	# Reset the buttons as well!!
	for button in _available_vbox.get_children():
		button.reset_button(orphan_id)
