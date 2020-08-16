# State is an autoload script that contains all global state variables.
extends Node

var _upgrade_resource := preload("res://src/autoload/state/Upgrade.gd")

### GLOBAL CONSTANTS ##########################################################

## UPGRADES ####################################################################
var upgrades := []

func add_upgrade_by_id(upgrade_id : String) -> void:
	var upgrade := _upgrade_resource.new()
	upgrade.id = upgrade_id

	var data := {}
	if Flow.upgrades_data.has(upgrade_id):
		data = Flow.upgrades_data[upgrade_id]
	else:
		push_error("Missing upgrade with id '{0}' in data.JSON".format([upgrade_id]))

	upgrade.text = data.get("text", "MISSING_TEXT")
	upgrade.description = data.get("description", "MISSING DESCRIPTION")
	upgrade.grid = data.get("grid", [])
	upgrade.color = data.get("color", Color.white)

	upgrade.effects = data.get("effects", {})

	print("appending!!!")
	upgrades.append(upgrade)

func get_upgrades_by_id() -> Array:
	var upgrade_ids := []
	for upgrade in upgrades:
		upgrade_ids.append(upgrade.id)
	return upgrade_ids
