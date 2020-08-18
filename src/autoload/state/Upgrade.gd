extends Reference
class_name class_upgrade

var id := ""

var orphan : class_orphan setget set_orphan, get_orphan
func set_orphan(value : class_orphan) -> void:
	_orphan = weakref(value)
func get_orphan():
	return _orphan.get_ref()

var _orphan := WeakRef.new()

func get_grid_positions() -> Array:
	var grid_positions := []
	# Get the grid from the data!
	var _grid = self.grid
	for row_index in range(0, _grid.size()):
		for column_index in range(0, _grid.size()):
			if _grid[row_index][column_index] == 1:
				grid_positions.append(Vector2(row_index, column_index))
	return grid_positions

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
	return Flow.get_upgrade_value(id, "name", "MISSING NAME")

var effect : Dictionary setget , get_effect
func get_effect():
	return Flow.get_upgrade_value(id, "effect", {})

var grid : Array setget , get_grid
func get_grid():
	return Flow.get_upgrade_value(id, "grid", [])
