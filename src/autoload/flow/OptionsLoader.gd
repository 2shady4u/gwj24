# Loader/saver for all the configuration variables.
extends Node

func load_optionsCFG() -> int:
	## Load the game and editor options and settings from both the default and the user-modified one.
	var config : ConfigFile = ConfigFile.new()
	var error : int = config.load(Flow.OPTIONS_PATH)
	if error == OK: # if not, something went wrong with the file loading.
		error = _parse_config(config)
		print("Succesfully loaded and processed '{0}'.".format([Flow.OPTIONS_PATH]))
		return OK
	else:
		push_error("Failed to open '{0}', check file availability!".format([Flow.OPTIONS_PATH]))
		return error

func _parse_config(config : ConfigFile) -> int:
	## Load all configuration variables to the ConfigData autoload script.
	for section_id in config.get_sections():
		for key in config.get_section_keys(section_id):
			if ConfigData.get(key) != null:
				ConfigData.set(key, config.get_value(section_id, key, ConfigData.get(key)))
			else:
				push_error("Failed to set configuration property {0}!".format([key]))
	return OK
