extends Reference
class_name class_mission

var id := ""
var completed := false

func _ready():
	pass # Replace with function body.

var context : Dictionary setget set_context, get_context
func set_context(value : Dictionary) -> void:
	if not value.has("id"):
		push_error("Mission context requires id!")

	id = value.id
	completed = value.get("completed", false)

func get_context() -> Dictionary:
	var _context := {}

	# Only save the mission to the context if it is completed!
	if completed:
		_context.id = id
		_context.completed = true

	return _context

var locked : bool setget , get_locked
func get_locked():
	# Check if the mission is locked or unlocked depending on prereq!
	var _prerequisites : Array = self.prerequisites
	for mission in State.missions:
		if mission.id in _prerequisites and not mission.completed:
			return true
	return false

# These are all constants derived from data.JSON and should be treated as such!
var name : String setget , get_name
func get_name():
	return Flow.get_mission_value(id, "name", "MISSING NAME")

var description : String setget , get_description
func get_description():
	return Flow.get_mission_value(id, "description", "MISSING DESCRIPTION")

var thumbnail_texture : String setget , get_thumbnail_texture
func get_thumbnail_texture():
	return Flow.get_mission_value(id, "thumbnail_texture", DEFAULT_THUMBNAIL_TEXTURE)

const DEFAULT_THUMBNAIL_TEXTURE := "res://assets/graphics/thumbnails/thumbnail_intro.png"

var prerequisites : Array setget , get_prerequisites
func get_prerequisites():
	return Flow.get_mission_value(id, "prerequisites", [])

var packed_scene : String setget , get_packed_scene
func get_packed_scene():
	return Flow.get_mission_value(id, "packed_scene",  "res://src/game/mission/TestMission.tscn")
