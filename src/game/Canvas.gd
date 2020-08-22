extends Node2D

func _ready():
	if not LevelFlow.current_mission_packed_scene_path:
		var mission_to_load = load("res://src/game/mission/TestMission.tscn").instance()
		add_child(mission_to_load)
		return
	print("Trying to load ", LevelFlow.current_mission_packed_scene_path)
	var mission_to_load = load(LevelFlow.current_mission_packed_scene_path).instance()
	add_child(mission_to_load)
