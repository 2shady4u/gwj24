extends Control

onready var _start_button := $VBoxContainer/VBoxContainer/StartButton
onready var _quit_button := $VBoxContainer/VBoxContainer/QuitButton

func _ready():
	if ConfigData.skip_menu:
		if ConfigData.verbose_mode : print("Automatically skipping menu as requested by configuration data...")
		Flow.change_scene_to("game")
	else:
		_start_button.grab_focus()

	var _error : int = _start_button.connect("pressed", self, "_on_start_button_pressed")
	if OS.get_name() == "HTML5":
		_quit_button.visible = false
	else:
		_quit_button.visible = true
		_error = _quit_button.connect("pressed", self, "_on_quit_button_pressed")

func _on_start_button_pressed():
	Flow.change_scene_to("game")

func _on_quit_button_pressed():
	Flow.deferred_quit()
