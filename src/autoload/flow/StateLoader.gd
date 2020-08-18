# Loads and saves the game's state from JSON.
extends Node

func _ready():
	## If it doesn't exist, create the saves-folder in user://
	var dir : Directory = Directory.new()
	if not dir.dir_exists(Flow.SAVE_FOLDER):
		print("Creating saves-folder at '{0}' (First-time initialization).".format([Flow.SAVE_FOLDER]))
		var error : int = dir.make_dir(Flow.SAVE_FOLDER)
		if error != OK:
			push_error("Failed to create saves-folder due to error '{0}'.".format([error]))

func load_stateJSON(path : String = Flow.DEFAULT_CONTEXT_PATH) -> int:
	## Load a previous State from a file defined in the user://saves-folder or the default one.
	var context : Dictionary = Flow.load_JSON(path)
	if not context.empty():
		State.load_state_from_context(context)
		return OK
	else:
		return ERR_FILE_CORRUPT

func save_stateJSON(path : String = Flow.USER_SAVE_PATH) -> int:
	## Save the current State to the user://saves-folder.
	var context : Dictionary = State.save_state_to_context()
	return Flow.save_JSON(path, context)
