extends MarginContainer
class_name class_mission_tab

onready var _title_label := $VBoxContainer/HBoxContainer/TitleLabel
onready var _description_label := $VBoxContainer/DescriptionLabel

onready var _start_button := $VBoxContainer/HBoxContainer/StartButton

var id := ""

var title := "" setget set_title, get_title
func set_title(value : String) -> void:
	_title_label.text = value
func get_title() -> String:
	return _title_label.text

var description := "" setget set_description, get_description
func set_description(value : String) -> void:
	_description_label.text = value
func get_description() -> String:
	return _description_label.text

func _ready():
	var _error : int = _start_button.connect("pressed", self, "_on_start_button_pressed")

func _on_start_button_pressed():
	Flow.change_scene_to("game")
