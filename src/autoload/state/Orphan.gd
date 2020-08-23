extends Reference
class_name class_orphan

var id := ""
var upgrades := []

var context : Dictionary setget set_context, get_context
func set_context(value : Dictionary) -> void:
	if not value.has("id"):
		push_error("Orphan context requires id!")
		return

	id = value.id
	# Try to find all upgrades that are owned by this orphan!
	for upgrade in State.upgrades:
		if upgrade.orphan_id == id:
			upgrades.append(upgrade)

func get_context() -> Dictionary:
	var _context := {}
	
	_context.id = id

	return _context

func add_upgrade(upgrade : class_upgrade, topmost_grid_position : Vector2 = Vector2.ZERO):
	if not upgrades.has(upgrade):
		upgrades.append(upgrade)

	upgrade.orphan_id = id
	upgrade.topmost_grid_position = topmost_grid_position

func remove_upgrade(upgrade : class_upgrade):
	upgrades.erase(upgrade)

	upgrade.orphan_id = ""
	upgrade.topmost_grid_position = Vector2.ZERO

func get_stats() -> Dictionary:
	var stats: Dictionary = get_base_stats().duplicate(true)
	for upgrade in upgrades:
		var effect = upgrade.effect
		for key in effect:
			stats[key] += effect[key]
	return stats

var columns : int setget , get_columns
func get_columns() -> int:
	return self.base_columns

# These are all constants derived from data.JSON and should be treated as such!
var name : String setget , get_name
func get_name():
	return Flow.get_orphan_value(id, "name", "MISSING NAME")

var backstory : String setget , get_backstory
func get_backstory():
	return Flow.get_orphan_value(id, "backstory", "MISSING BACKSTORY")

var perk_ids : Array setget , get_perk_ids
func get_perk_ids():
	return Flow.get_orphan_value(id, "perk_ids", [])

var portrait_texture : String setget , get_portrait_texture
func get_portrait_texture():
	return Flow.get_orphan_value(id, "portrait_texture", "res://assets/graphics/portraits/regular.png")

var icon_texture : String setget , get_icon_texture
func get_icon_texture():
	return Flow.get_orphan_value(id, "icon_texture", "res://assetsgraphics/characters/Children/S0HN.png")

var base_columns : int setget , get_base_columns
func get_base_columns():
	return Flow.get_orphan_value(id, "base_columns", 3)

var base_stats : Dictionary setget , get_base_stats
func get_base_stats():
	return Flow.get_orphan_value(id, "base_stats", DEFAULT_BASE_STATS)

const DEFAULT_BASE_STATS := {
	"health": 5,
	"damage": 1,
	"healing": 1,
	"healing_charges": 2,
	"actions": 2,
	"movement": 4
}
