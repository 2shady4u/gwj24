extends Node

enum STATE {MENU, GAME}

const OPTIONS_PATH := "res://options.cfg"

const CONTROLS_PATH := "res://controls.json"

const SAVE_FOLDER := "user://saves"

const DEFAULT_CONTEXT_PATH := "res://default_context.json"
const USER_SAVE_PATH := SAVE_FOLDER + "/user_save.json"

const DATA_PATH := "res://assets/data.json"

### PUBLIC VARIABLES ###
var pause_UI : Control = null

# Is the game currently in editor mode? or not?
var is_in_editor_mode := false
var verbose_mode := true

var upgrades_data := {}
var orphans_data := {}
var enemies_data := {}

# WHY is this an array? Missions need their order to be preserved!!!
var missions_data := []

var _game_flow := {
	"menu": {
		"packed_scene": preload("res://src/Menu.tscn"),
		"state": STATE.MENU
		},
	"game": {
		"packed_scene": preload("res://src/Game.tscn"),
		"state": STATE.GAME
		},
	}
var _game_state : int = STATE.MENU

onready var _options_loader := $OptionsLoader
onready var _controls_loader := $ControlsLoader
onready var _data_loader := $DataLoader
onready var _state_loader := $StateLoader

func _ready():
	var _error := load_settings()

func load_settings() -> int:
	print("----- (Re)loading game settings from file -----")
	var _error : int = _options_loader.load_optionsCFG()
	_error += _controls_loader.load_controlsJSON()
	_error += _data_loader.load_dataJSON()
	# Also load the default context!?
	_error += _state_loader.load_stateJSON()
	if _error == OK:
		print("----> Succesfully loaded settings!")
	else:
		push_error("Failed to load settings! Check console for clues!")
	return _error

func _unhandled_input(event : InputEvent):
## Catch all unhandled input not caught be any other control nodes.
	if InputMap.has_action("toggle_full_screen") and event.is_action_pressed("toggle_full_screen"):
		OS.window_fullscreen = not OS.window_fullscreen

	if InputMap.has_action("restart") and event.is_action_pressed("restart"):
		call_deferred("deferred_reload_current_scene")

	match _game_state:
		STATE.GAME:
			if InputMap.has_action("toggle_paused") and event.is_action_pressed("toggle_paused"):
				toggle_paused()

func toggle_paused():
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		pause_UI.show()
	else:
		pause_UI.hide()

func deferred_quit() -> void:
## Quit the game during an idle frame.
	get_tree().quit()

func deferred_reload_current_scene() -> void:
## It is now safe to reload the current scene.
	var _error := load_settings()
	_error = get_tree().reload_current_scene()
	get_tree().paused = false

func change_scene_to(key : String) -> void:
	if _game_flow.has(key):
		var state_settings : Dictionary = _game_flow[key]
		var packed_scene : PackedScene = state_settings.packed_scene
		_game_state = state_settings.state

		var error := get_tree().change_scene_to(packed_scene)
		get_tree().paused = false
		if error != OK:
			push_error("Failed to change scene to '{0}'.".format([key]))
		else:
			print("Succesfully changed scene to '{0}'.".format([key]))
	else:
		push_error("Requested scene '{0}' was not recognized... ignoring call for changing scene.".format([key]))

func get_upgrade_value(id : String, key : String, default):
	if upgrades_data.has(id):
		var data : Dictionary = upgrades_data[id]
		return data.get(key, default)
	else:
		return default

func get_orphan_value(id : String, key : String, default):
	if orphans_data.has(id):
		var data : Dictionary = orphans_data[id]
		return data.get(key, default)
	else:
		return default

func get_enemy_value(id : String, key : String, default):
	if enemies_data.has(id):
		var data : Dictionary = enemies_data[id]
		return data.get(key, default)
	else:
		return default

func get_mission_value(id : String, key : String, default):
	for data in missions_data:
		if data.get("id", "MISSING ID") == id:
			return data.get(key, default)

	return default

func does_mission_exist(id: String):
	for data in missions_data:
		if data.get("id", "MISSING ID") == id:
			return true
	return false

func new_game() -> void:
	_state_loader.load_stateJSON()

func save_game() -> void:
	print("Saving game context to '{0}'".format([Flow.USER_SAVE_PATH]))
	_state_loader.save_stateJSON()

func load_game():
	_state_loader.load_stateJSON(Flow.USER_SAVE_PATH)

static func load_JSON(path : String) -> Dictionary:
# Load a JSON-file, convert it to a dictionary and return it.
	var file : File = File.new()
	var dictionary := {}
	var error : int = file.open(path, File.READ)
	if error == OK:
		var text : String = file.get_as_text()
		file.close()
		if typeof(parse_json(text)) != TYPE_NIL:
			dictionary = parse_json(text)
			if dictionary == null:
				push_error("Detected null-value in JSON at {0}.".format([path]))
			else:
				return dictionary

		push_error("Failed to correctly process '{0}', check file format!".format([path]))
		return {}
	else:
		push_error("Failed to open '{0}', check file availability!".format([path]))
		return {}

static func save_JSON(path : String, dictionary : Dictionary) -> int:
## Save a dictionary, in JSON format, to a file.
	var file : File = File.new()
	var error : int = file.open(path, File.WRITE)
	if error == OK:
		var text : String = to_json(dictionary)
		text = JSONBeautifier.beautify_json(text)
		file.store_string(text)
		file.close()

		print("Succesfully saved '{0}'.".format([path]))
		return OK
	else:
		push_error("Could not open file for writing purposes '{0}', check if file is locked!".format([path]))
		return error
