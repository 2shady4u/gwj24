# Loader for all the game's data.
extends Node

func load_dataJSON() -> int:
	## Load all characters, objects, regions, etc... from the data JSON.
	var file : File = File.new()
	var error : int = OK
	if file.file_exists(Flow.DATA_PATH):
		if ConfigData.verbose_mode: print("Attempting to load essential game data from '{0}'.".format([Flow.DATA_PATH]))
		var data : Dictionary = Flow.load_JSON(Flow.DATA_PATH)
		if data.empty():
			push_error("Failed to open the data settings at '{0}' for loading purposes.".format([Flow.DATA_PATH]))
		else:
			Flow.upgrades_data = data.get("upgrades", {})
			Flow.orphans_data = data.get("orphans", {})


			Flow.allies_data = data.get("allies", {})
			Flow.enemies_data = data.get("enemies", {})

			Flow.missions_data = data.get("missions", [])

			Flow.perks_data = data.get("perks", {})
	
	else:
		push_error("Essential file '{0}' does not exist, check its existence!".format([Flow.DATA_PATH]))
		return ERR_FILE_CORRUPT
	return error
