extends Node2D
class_name DialogueEvent

export(String, "fiston", "sonic", "bebe", "sohn", "sorella", "mother", "variable") var speaker: String = "fiston"
export(String, MULTILINE) var text = ""
export(NodePath) var path

onready var children = get_children()

func _ready():
	pass
	
func get_points():
	var points = []
	for child in children:
		points.append(position + child.position)
	return points
