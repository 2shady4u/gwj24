# Loader/saver for all the configuration variables.
extends Node

func load_optionsCFG() -> int:
	## Load the game and editor options and settings from both the default and the user-modified one.
	var config : ConfigFile = ConfigFile.new()
	var file : File = File.new()
	var error : int = config.load(Flow.OPTIONS_PATH)
	if error == OK: # if not, something went wrong with the file loading.
		error = _parse_config(config)
		print("Succesfully loaded and processed '{0}'.".format([Flow.OPTIONS_PATH]))
		# Check if there are any user-modified options that need to be overwritten.
		if file.file_exists(Flow.USER_SETTINGS_PATH):
			print("Attempting to load user-modified settings from '{0}'.".format([Flow.USER_SETTINGS_PATH]))
			error = config.load(Flow.USER_SETTINGS_PATH)
			if error == OK: # if not, something went wrong with the file loading.
				error = _parse_config(config)
				print("Succesfully loaded and processed '{0}'.".format([Flow.USER_SETTINGS_PATH]))
				return OK
			else:
				push_error("Failed to load '{0}', check file format!".format([Flow.OPTIONS_PATH]))
				return error
		else:
			return OK
	else:
		push_error("Failed to open '{0}', check file availability!".format([Flow.OPTIONS_PATH]))
		return error

func save_settingsCFG() -> int:
	## Save settings that can be user-modified to a configuration file.
	var config : ConfigFile = ConfigFile.new()
	var error : int = config.load(Flow.OPTIONS_PATH)
	if error == OK: # if not, something went wrong with the file loading.
		for section_id in config.get_sections():
			# Only save the sections that begin with "settings"!
			if section_id.begins_with("settings"):
				for key in config.get_section_keys(section_id):
					if ConfigData.get(key) != null:
						config.set_value(section_id, key, ConfigData.get(key))
					else:
						push_error("Failed to set configuration property {0}!".format([key]))
			else: # Erase the section, since it doesnt pertain to any user-modifiable settings!
				config.erase_section(section_id)
		return config.save(Flow.USER_SETTINGS_PATH)
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
