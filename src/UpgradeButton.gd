extends Button
class_name class_upgrade_button

var _upgrade_resource := preload("res://src/Upgrade.gd")

var upgrade : class_upgrade = null

signal button_toggled()

func _ready():
	connect("toggled", self, "_on_button_toggled")

func create_upgrade(upgrade_id, upgrade_data):
	upgrade = _upgrade_resource.new()

	upgrade.id = upgrade_id
	upgrade.grid = upgrade_data.grid
	upgrade.color = upgrade_data.color
	
	upgrade.effects = upgrade_data.effects

	text = upgrade_data.text

func _on_button_toggled(button_pressed : bool):
	emit_signal("button_toggled", upgrade, button_pressed)
	release_focus()
