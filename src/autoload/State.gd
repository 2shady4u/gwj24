# State is an autoload script that contains all global state variables.
extends Node

var _upgrade_resource := preload("res://src/autoload/state/Upgrade.gd")
var _orphan_resource := preload("res://src/autoload/state/Orphan.gd")

### GLOBAL CONSTANTS ##########################################################

## STATE ######################################################################

func load_state_from_context(context : Dictionary):
	print_debug("Loading state from the context...")

	for orphan_context in context.get("orphans", {}):
		add_orphan_from_context(orphan_context)

	for upgrade_context in context.get("upgrades", {}):
		add_upgrade_from_context(upgrade_context)
	
func save_state_to_context() -> Dictionary:
	var context := {}

	context["orphans"] = []
	for orphan in orphans:
		context["orphans"].append(orphan.context)

	context["upgrades"] = []
	for upgrade in upgrades:
		context["upgrades"].append(upgrade.context)

	return context

## UPGRADES ####################################################################
var orphans := []

func add_new_orphan(orphan_id : String) -> void:
	var orphan := _orphan_resource.new()
	orphan.id = orphan_id

	print_debug("adding brand-new orphan with id '{0}' to State!".format([orphan_id]))
	orphans.append(orphan)

func add_orphan_from_context(orphan_context : Dictionary) -> void:
	var orphan := _orphan_resource.new()
	orphan.context = orphan_context
	
	orphans.append(orphan)

func get_orphan_by_id(orphan_id : String):
	for orphan in orphans:
		if orphan.id == orphan_id:
			return orphan
	push_error("Orphan with id '{0}' is not available in the State!".format([orphan_id]))
	return null

## UPGRADES ####################################################################
var upgrades := []

func add_new_upgrade(upgrade_id : String) -> void:
	var upgrade := _upgrade_resource.new()
	upgrade.id = upgrade_id

	print_debug("adding brand-new upgrade with id '{0}' to State!".format([upgrade_id]))
	upgrades.append(upgrade)

func add_upgrade_from_context(upgrade_context : Dictionary) -> void:
	var upgrade := _upgrade_resource.new()
	upgrade.context = upgrade_context

	upgrades.append(upgrade)

func get_upgrades_by_id() -> Array:
	var upgrade_ids := []
	for upgrade in upgrades:
		upgrade_ids.append(upgrade.id)
	return upgrade_ids
