extends class_menu_tab

onready var _mission_button := $VBoxContainer/VBoxContainer/MissionButton
onready var _settings_button := $VBoxContainer/VBoxContainer/SettingsButton
onready var _quit_button := $VBoxContainer/VBoxContainer/QuitButton

func _ready():
	var _error : int = _mission_button.connect("pressed", self, "_on_mission_button_pressed")
	_error = _settings_button.connect("pressed", self, "_on_settings_button_pressed")

	if OS.get_name() == "HTML5":
		_quit_button.visible = false
	else:
		_quit_button.visible = true
		_error = _quit_button.connect("pressed", self, "_on_quit_button_pressed")

func update_tab():
	_mission_button.grab_focus()

func _on_settings_button_pressed():
	emit_signal("button_pressed", TABS.SETTINGS)

func _on_mission_button_pressed():
	emit_signal("button_pressed", TABS.MISSION)
