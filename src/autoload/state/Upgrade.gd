extends Reference
class_name class_upgrade

var id := ""
var orphan_id := ""
var topmost_grid_position := Vector2.ZERO

var grid_positions : Array setget , get_grid_positions
func get_grid_positions() -> Array:
	var _grid_positions := []
	# Get the grid from the data!
	var _grid = self.grid
	for row_index in range(0, _grid.size()):
		for column_index in range(0, _grid[row_index].size()):
			if _grid[row_index][column_index] == 1:
				var grid_position = Vector2(row_index, column_index)
				# Offset the position with the topmost position!
				grid_position += topmost_grid_position
				_grid_positions.append(grid_position)
	return _grid_positions

var context : Dictionary setget set_context, get_context
func set_context(value : Dictionary) -> void:
	if not value.has("id"):
		push_error("Upgrade context requires id!")
		return

	id = value.id
	orphan_id = value.get("orphan_id", "")
	if not orphan_id.empty():
		var topmost_grid_array : Array = value.get("topmost_grid_position", [0, 0])
		if topmost_grid_array.size() == 2:
			topmost_grid_position = Vector2(topmost_grid_array[0], topmost_grid_array[1])
		else:
			push_error("Field 'topmost_grid_position' contained more or less than 2 elements!")

func get_context() -> Dictionary:
	var _context := {}

	_context.id = id
	if not orphan_id.empty():
		_context.orphan_id = orphan_id
		_context.topmost_grid_position = [topmost_grid_position.x, topmost_grid_position.y]

	return _context

# These are all constants derived from data.JSON and should be treated as such!
var name : String setget , get_name
func get_name() -> String:
	return Flow.get_upgrade_value(id, "name", "MISSING NAME")

var description : String setget , get_description
func get_description() -> String:
	return Flow.get_upgrade_value(id, "description", "MISSING DESCRIPTION")

var effect : Dictionary setget , get_effect
func get_effect() -> Dictionary:
	return Flow.get_upgrade_value(id, "effect", {})

var grid : Array setget , get_grid
func get_grid() -> Array:
	return Flow.get_upgrade_value(id, "grid", [])

var grid_texture : String setget , get_grid_texture
func get_grid_texture() -> String:
	return Flow.get_upgrade_value(id, "grid_texture", "res://assets/graphics/upgrades/Chip_Empty.png")
