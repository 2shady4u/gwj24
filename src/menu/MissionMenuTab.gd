extends class_menu_tab

onready var _back_button := $BackContainer/BackButton

onready var _orphan_button := $VBoxContainer/OrphanButton

onready var _mission_button_vbox := $VBoxContainer/HBoxContainer/ScrollContainer/MissionButtonVBox
onready var _mission_tab_container := $VBoxContainer/HBoxContainer/VBoxContainer/MissionTabContainer

var _mission_button_resource := preload("res://src/menu/MissionButton.tscn")
var _mission_tab_resource := preload("res://src/menu/MissionTab.tscn")

func _ready():
	var _error : int = _back_button.connect("pressed", self, "_on_back_button_pressed")
	_error = _orphan_button.connect("pressed", self, "_on_orphan_button_pressed")

	for child in _mission_button_vbox.get_children():
		_mission_button_vbox.remove_child(child)
		child.queue_free()
	for child in _mission_tab_container.get_children():
		_mission_tab_container.remove_child(child)
		child.queue_free()
	
	for mission in Flow.missions_data:
		var button := _mission_button_resource.instance()
		_mission_button_vbox.add_child(button)

		button.text = mission.get("title", "MISSING TITLE")

		_error = button.connect("pressed", self, "_on_mission_button_pressed", [mission.id])

		var tab := _mission_tab_resource.instance()
		_mission_tab_container.add_child(tab)

		tab.id = mission.id
		tab.title = mission.get("title", "MISSING TITLE")
		tab.description = mission.get("description", "MISSING DESCRIPTION")

func _on_mission_button_pressed(mission_id : String):
	print(mission_id)
	var index := 0
	for child in _mission_tab_container.get_children():
		if child is class_mission_tab:
			if child.id == mission_id:
				_mission_tab_container.current_tab = index
				return
		index += 1

func _on_back_button_pressed():
	emit_signal("button_pressed", TABS.MAIN)

func _on_orphan_button_pressed():
	emit_signal("button_pressed", TABS.ORPHAN)

func _on_start_button_pressed():
	Flow.change_scene_to("game")