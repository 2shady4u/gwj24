extends Reference
class_name class_orphan

var id := ""
var grid_positions := PoolVector2Array()
var upgrades := []

var grid : Array = [] setget set_grid
func set_grid(value : Array) -> void:
	grid = value
	for row_index in range(0, grid.size()):
		for column_index in range(0, grid[row_index].size()):
			if grid[row_index][column_index] == 1:
				grid_positions.append(Vector2(row_index, column_index))

var context : Dictionary setget set_context, get_context
func set_context(value : Dictionary) -> void:
	if not value.has("id"):
		push_error("Upgrade context requires id!")

	id = value.id

func get_context() -> Dictionary:
	var _context := {}
	
	_context.id = id
	
	return _context

# These are all constants derived from data.JSON and should be treated as such!
var name : String setget , get_name
func get_name():
	return Flow.get_orphan_value(id, "name", "MISSING NAME")

var backstory : String setget , get_backstory
func get_backstory():
	return Flow.get_orphan_value(id, "backstory", "MISSING BACKSTORY")

var base_stats : Dictionary setget , get_base_stats
func get_base_stats():
	return Flow.get_orphan_value(id, "base_stats", DEFAULT_BASE_STATS)

const DEFAULT_BASE_STATS := {
	"health": 5,
	"damage": 1,
	"healing": 1,
	"actions": 2,
	"movement": 4
}
