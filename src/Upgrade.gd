extends Reference
class_name class_upgrade

var id := ""
var color := Color.white
var grid_positions := PoolVector2Array()

var effects := {}

var grid : Array setget set_grid
func set_grid(value : Array) -> void:
	grid = value
	for row_index in range(0, grid.size()):
		for column_index in range(0, grid[row_index].size()):
			if grid[row_index][column_index] == 1:
				grid_positions.append(Vector2(row_index, column_index))

func move(movement_direction : Vector2, columns : int):
	var new_positions := grid_positions
	for i in range(0, new_positions.size()):
		new_positions[i] += movement_direction
		if new_positions[i].x < 0 or new_positions[i].x > columns-1:
			return
		if new_positions[i].y < 0 or new_positions[i].y > columns-1:
			return
	grid_positions = new_positions
