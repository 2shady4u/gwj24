extends HBoxContainer
class_name class_orphan_tab

onready var _grid_container := $GridVBox/Control/PanelContainer/GridContainer

onready var _name_label := $VBoxContainer/BioHBox/ScrollContainer/VBoxContainer/HBoxContainer/NameLabel
onready var _back_story_label := $VBoxContainer/BioHBox/ScrollContainer/VBoxContainer/BackStoryLabel
onready var _portrait_rect := $VBoxContainer/BioHBox/Control/PortraitRect

onready var _health_label := $VBoxContainer/StatsHBox/GridContainer/HealthLabel
onready var _damage_label := $VBoxContainer/StatsHBox/GridContainer/DamageLabel
onready var _healing_label := $VBoxContainer/StatsHBox/GridContainer/HealingLabel
onready var _movement_label := $VBoxContainer/StatsHBox/GridContainer/MovementLabel
onready var _actions_label := $VBoxContainer/StatsHBox/GridContainer/ActionsLabel
onready var _healing_charges_label := $VBoxContainer/StatsHBox/GridContainer/HealingChargesLabel

onready var _perk_container := $VBoxContainer/StatsHBox/ScrollContainer/PerkContainer

var _upgrade_slot_resource := preload("res://src/menu/orphan/UpgradeSlot.tscn")
var _perk_vbox_resource := preload("res://src/menu/orphan/PerkVBox.tscn")

var orphan : class_orphan setget set_orphan, get_orphan
func set_orphan(value : class_orphan) -> void:
	_orphan = weakref(value)

	_name_label.text = value.name
	_back_story_label.text = value.backstory
	_portrait_rect.texture = load(value.portrait_texture)

	update_stats()
	update_tab()
func get_orphan():
	return _orphan.get_ref()

var _orphan := WeakRef.new()

var active_upgrade : class_upgrade setget set_active_upgrade, get_active_upgrade
func set_active_upgrade(value : class_upgrade) -> void:
	var old_upgrade = self.active_upgrade
	_active_upgrade = weakref(value)

	for child in _grid_container.get_children():
		if child.active_upgrade == old_upgrade:
			child.active_upgrade = null
		if child.upgrade == value:
			child.upgrade = null

		if value:
			if child.grid_position in value.grid_positions:
				child.active_upgrade = value
			else:
				child.active_upgrade = null
		else:
			child.active_upgrade = null
func get_active_upgrade():
	return _active_upgrade.get_ref()
var _active_upgrade := WeakRef.new()

signal upgrade_placed()

signal upgrade_mouse_entered(class_upgrade)
signal upgrade_mouse_exited()

func _ready():
	set_process_input(false)

func update_stats():
	var base_stats := self.orphan.base_stats
	var stats := self.orphan.get_stats()

	for key in base_stats.keys():
		var base_stat = base_stats[key]
		var stat = stats.get(key, base_stats[key])
		match key:
			"health":
				update_stat_label(_health_label, base_stat, stat)
			"damage":
				update_stat_label(_damage_label, base_stat, stat)
			"healing":
				update_stat_label(_healing_label, base_stat, stat)
			"movement":
				update_stat_label(_movement_label, base_stat, stat)
			"actions":
				update_stat_label(_actions_label, base_stat, stat)
			"healing_charges":
				update_stat_label(_healing_charges_label, base_stat, stat)

func update_stat_label(label : Label, base_stat : float, stat : float):
	label.text = str(base_stat)
	var stat_diff = stat - base_stat
	if stat_diff == 0.0:
		return
	elif stat_diff > 0:
		label.text += " + "
	else:
		label.text += " - "
	label.text += str(abs(stat_diff))

func update_tab():
	clear_tab()
 
	for perk_id in self.orphan.perk_ids:
		var perk_vbox = _perk_vbox_resource.instance()
		_perk_container.add_child(perk_vbox)

		perk_vbox.text = Flow.get_perk_value(perk_id, "name", "MISSING NAME")
		perk_vbox.description = Flow.get_perk_value(perk_id, "description", "MISSING DESCRIPTION")

	var columns := self.orphan.columns
	_grid_container.columns = columns
	for row_index in range(0, columns):
		for column_index in range(0, columns):
			var slot = _upgrade_slot_resource.instance()
			_grid_container.add_child(slot)
			
			var _error : int = slot.connect("slot_mouse_entered", self, "_on_slot_mouse_entered")
			_error = slot.connect("slot_mouse_exited", self, "_on_slot_mouse_exited")

			slot.grid_position = Vector2(row_index, column_index)
			match columns:
				3:
					slot.rect_min_size = 64*Vector2.ONE
					slot.rect_size = 64*Vector2.ONE
				4:
					slot.rect_min_size = 48*Vector2.ONE
					slot.rect_size = 48*Vector2.ONE

	# Place the orphan's upgrades in its grid!
	for upgrade in self.orphan.upgrades:
		place_upgrade_on_grid(upgrade)

func clear_tab():
	for child in _grid_container.get_children():
		_grid_container.remove_child(child)
		child.queue_free()
	
	for child in _perk_container.get_children():
		_perk_container.remove_child(child)
		child.queue_free()

func _on_slot_mouse_entered(upgrade : class_upgrade):
	emit_signal("upgrade_mouse_entered", upgrade)

func _on_slot_mouse_exited():
	emit_signal("upgrade_mouse_exited")

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
		if self.active_upgrade:
			var success = place_upgrade_on_grid(self.active_upgrade)
			if success:
				emit_signal("upgrade_placed")

func place_upgrade_on_grid(upgrade : class_upgrade) -> bool:
	# First check if the upgrade can actually be placed!
	var potential_slots := []
	for grid_position in upgrade.grid_positions:
		var slot := get_slot_at_grid_position(grid_position)
		if slot == null or slot.upgrade != null:
			# The grid position fell outside the available grid???
			# OR
			# There's already an upgrade at this position!
			# Be sure to reset the upgrade to default! (= without orphan)
			self.orphan.remove_upgrade(upgrade)
			# AND to enable the button again!
			# HOW ???
			return false
		potential_slots.append(slot)

	# If we got through this entire thing without returning.. we are free to add the upgrade!
	for slot in potential_slots:
		slot.upgrade = upgrade
	var topmost_grid_position = upgrade.topmost_grid_position
	self.orphan.add_upgrade(upgrade, topmost_grid_position)
	update_stats()
	return true

func remove_upgrade_from_grid(upgrade : class_upgrade) -> bool:
	if upgrade in self.orphan.upgrades:
		for grid_position in upgrade.grid_positions:
			var slot := get_slot_at_grid_position(grid_position)
			slot.upgrade = null
		AudioEngine.play_effect("ui_chip_out")
		self.orphan.remove_upgrade(upgrade)
		update_stats()
		return true
	else:
		return false

func get_slot_at_grid_position(grid_position : Vector2) -> class_upgrade_slot:
	for child in _grid_container.get_children():
		if child.grid_position == grid_position:
			return child
	return null

func move_active_upgrade(movement_direction : Vector2):
	var columns := self.orphan.columns
	var upgrade = self.active_upgrade
	var potential_positions := []
	
	# First check if we can actually move the upgrade or not!!
	for slot in _grid_container.get_children():
		if slot.active_upgrade == upgrade:
			var position = slot.grid_position
			position += movement_direction
			if position.x < 0 or position.x > columns-1:
				return
			if position.y < 0 or position.y > columns-1:
				return
			potential_positions.append(position)

	# If we got to here, then we are free to move the upgrade!
	for slot in _grid_container.get_children():
		if slot.grid_position in potential_positions:
			slot.active_upgrade = upgrade
		else:
			slot.active_upgrade = null

	# Don't forget to update the topmost position in the upgrade as well!
	if upgrade:
		upgrade.topmost_grid_position += movement_direction
