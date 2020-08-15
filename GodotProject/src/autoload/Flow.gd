extends Node

enum STATE {MENU, GAME}

const CONTROLS_PATH := "res://controls.json"

### PUBLIC VARIABLES ###
var pause_UI : Control = null

# Is the game currently in editor mode? or not?
var is_in_editor_mode := false
var verbose_mode := true

var _game_flow := {
	"game": {
		"packed_scene": preload("res://src/Game.tscn"),
		"state": STATE.GAME
		},
	}
var _game_state : int = STATE.GAME

onready var _controls_loader := $ControlsLoader

func _ready():
	var _error := load_settings()

func load_settings() -> int:
	print("----- (Re)loading game settings from file -----")
	var _error : int = _controls_loader.load_controlsJSON()
	if _error == OK:
		print("----> Succesfully loaded settings!")
	else:
		push_error("Failed to load settings! Check console for clues!")
	return _error

func _unhandled_input(event : InputEvent):
## Catch all unhandled input not caught be any other control nodes.
	if InputMap.has_action("toggle_full_screen") and event.is_action_pressed("toggle_full_screen"):
		OS.window_fullscreen = not OS.window_fullscreen

	match _game_state:
		STATE.GAME:
			if InputMap.has_action("toggle_paused") and event.is_action_pressed("toggle_paused"):
				toggle_paused()
			if InputMap.has_action("restart") and event.is_action_pressed("restart"):
				call_deferred("deferred_reload_current_scene")

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
