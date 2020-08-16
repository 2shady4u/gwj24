extends class_pause_tab

onready var _resume_button := $VBoxContainer/VBoxContainer/ResumeButton
onready var _restart_button := $VBoxContainer/VBoxContainer/RestartButton
onready var _settings_button := $VBoxContainer/VBoxContainer/SettingsButton
onready var _abort_button := $VBoxContainer/VBoxContainer/AbortButton
onready var _quit_button := $VBoxContainer/VBoxContainer/QuitButton

func _ready():
	var _error : int = _resume_button.connect("pressed", self, "_on_resume_button_pressed")
	_error = _restart_button.connect("pressed", self, "_on_restart_button_pressed")
	_error = _settings_button.connect("pressed", self, "_on_settings_button_pressed")
	_error = _abort_button.connect("pressed", self, "_on_abort_button_pressed")

	if OS.get_name() == "HTML5":
		_quit_button.visible = false
	else:
		_quit_button.visible = true
		_error = _quit_button.connect("pressed", self, "_on_quit_button_pressed")

func update_tab():
	_resume_button.grab_focus()

func _on_resume_button_pressed():
	Flow.toggle_paused()

func _on_restart_button_pressed():
	Flow.deferred_reload_current_scene()

func _on_settings_button_pressed():
	emit_signal("button_pressed", TABS.SETTINGS)

func _on_abort_button_pressed():
	Flow.change_scene_to("menu")
