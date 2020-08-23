extends MarginContainer
class_name class_mission_tab

onready var _name_label := $VBoxContainer/HBoxContainer/NameLabel
onready var _start_button := $VBoxContainer/StartButton

onready var _description_label := $VBoxContainer/ScrollContainer/VBoxContainer/DescriptionLabel
onready var _thumbnail_rect := $VBoxContainer/ScrollContainer/VBoxContainer/ThumbnailRect

onready var _status_label := $VBoxContainer/StatusLabel

const LOCKED_TEXT := "You do not meet the proper prerequisites...\nCome back later!"

var mission : class_mission setget set_mission, get_mission
func set_mission(value : class_mission) -> void:
	_mission = weakref(value)

	_name_label.text = value.name
	_thumbnail_rect.texture = load(value.thumbnail_texture)

	if value.locked:
		_thumbnail_rect.material.set_shader_param("locked", true)
		_start_button.disabled = true
		_start_button.visible = false

		_description_label.text = encrypt_with_ceaser_cipher(value.description)
		_status_label.visible = true
	else:
		_thumbnail_rect.material.set_shader_param("locked", false)
		_start_button.disabled = false
		_start_button.visible = true

		_description_label.text = value.description
		_status_label.visible = false

func get_mission() -> class_mission:
	return _mission.get_ref()

var _mission := WeakRef.new()

func _ready():
	var _error : int = _start_button.connect("pressed", self, "_on_start_button_pressed")

func _on_start_button_pressed():
	AudioEngine.play_effect("ui_select")
	print("Setting value ", self.mission.packed_scene)
	LevelFlow.current_mission_packed_scene_path = self.mission.packed_scene
	Flow.change_scene_to("game")

func encrypt_with_ceaser_cipher(input : String) -> String:
	var output := ""
	var s := 3

	for i in range(len(input)): 
		var substr := input.substr(i, 1)

		if substr == " ":
			output+= substr

		# Encrypt uppercase characters
		elif substr == substr.to_upper(): 
			output += char((ord(substr) + s - 65) % 26 + 65) 
 
		# Encrypt lowercase characters 
		else: 
			output += char((ord(substr) + s - 97) % 26 + 97) 
  
	return output 

func _on_button_mouse_entered():
	AudioEngine.play_effect("ui_move")
