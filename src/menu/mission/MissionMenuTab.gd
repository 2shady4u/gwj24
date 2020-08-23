extends class_menu_tab

onready var _back_button := $BackContainer/BackButton

onready var _orphan_button := $VBoxContainer/OrphanButton

onready var _mission_button_vbox := $VBoxContainer/HBoxContainer/ScrollContainer/MissionButtonVBox
onready var _mission_tab_container := $VBoxContainer/HBoxContainer/MissionTabContainer

var _mission_button_resource := preload("res://src/menu/mission/MissionButton.tscn")
var _mission_tab_resource := preload("res://src/menu/mission/MissionTab.tscn")

func _ready():
	var _error : int = _back_button.connect("pressed", self, "_on_back_button_pressed")
	_error = _orphan_button.connect("pressed", self, "_on_orphan_button_pressed")

func update_tab():
	clear_tab()

	for mission in State.missions:
		# Add mission tab
		var tab := _mission_tab_resource.instance()
		_mission_tab_container.add_child(tab)

		tab.mission = mission

		# Add mission button
		var button := _mission_button_resource.instance()
		_mission_button_vbox.add_child(button)

		button.text = mission.name

		var tab_idx = _mission_tab_container.get_tab_count() - 1
		var _error : int = button.connect("pressed", self, "_on_mission_button_pressed", [tab_idx])


	AudioEngine.play_background_music("mission_select")


func clear_tab():
	for child in _mission_button_vbox.get_children():
		_mission_button_vbox.remove_child(child)
		child.queue_free()
	for child in _mission_tab_container.get_children():
		_mission_tab_container.remove_child(child)
		child.queue_free()

func _on_mission_button_pressed(tab_idx : int):
	_mission_tab_container.current_tab = tab_idx

func _on_back_button_pressed():
	emit_signal("button_pressed", TABS.MAIN)

func _on_orphan_button_pressed():
	emit_signal("button_pressed", TABS.ORPHAN)

