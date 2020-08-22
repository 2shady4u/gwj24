extends Node2D
class_name Mission

export var identifier: String = ""

export var levels: Array = []

var current_level: Level = null
var current_level_scene: PackedScene = null

var surviving_characters: Dictionary = {}

# we're saving these here as a buffer and write them to the flow in case of mission completion
# the ones picked up in the level are lost when you restart the level
# but get added to chips stored after completing a level
var chips_stored = []
var chips_picked_up_in_level = []

func _ready():
	if identifier == "":
		printerr("No valid identifier for mission")
	elif not Flow.does_mission_exist(identifier):
		printerr("Mission identifier does not exist")
	
	print(levels)
	print(levels[0])
	load_level(levels[0])
	
func update_surviving_characters():
	surviving_characters = {}
	var player_characters = current_level.get_player_characters()
	for player_character in player_characters:
		surviving_characters[player_character.type] = {
			"hp": player_character.current_health,
			"healing_charges": player_character.healing_charges_left,
		}

func load_surviving_characters():
	if len(surviving_characters) == 0:
		print("First level of the mission!")
		return
	else:
		print("Loading surviving characters! ", surviving_characters)
		var player_characters = current_level.get_player_characters()
		for player_character in player_characters:
			if player_character.type in surviving_characters:
				player_character.current_health = surviving_characters[player_character.type].hp
				player_character.healing_charges_left = surviving_characters[player_character.type].healing_charges
			else:
				# don't want to delete her the moment she's introduced
				if player_character.type != "mother":
					player_character.queue_free()
					player_character.hide()
					
func load_level(level_scene: PackedScene) -> Level:
	if current_level:
		current_level.disconnect("failed", self, "on_level_failed")
		current_level.disconnect("complete", self, "on_level_complete")
		current_level.disconnect("chip_pickup", self, "on_chip_pickup")
		current_level.queue_free()
		remove_child(current_level)
		current_level = null
	
	var level: Level = level_scene.instance()

	add_child(level)
	current_level = level
	current_level_scene = level_scene
	current_level.connect("failed", self, "on_level_failed")
	current_level.connect("complete", self, "on_level_complete")
	current_level.connect("chip_pickup", self, "on_chip_pickup")
	load_surviving_characters()
	return level

func on_chip_pickup(chip: String):
	chips_picked_up_in_level.append(chip)

func restart_level():
	load_level(current_level_scene)

func on_level_failed():
	print("Level failed")
	load_level(current_level_scene)
	
func transfer_chips_from_level():
	for chip in chips_picked_up_in_level:
		chips_stored.append(chip)
	chips_picked_up_in_level = []
	
func transfer_chips_to_save():
	# TODO
	pass
	
func set_mission_completed():
	print("Mission is finished!!")
	transfer_chips_to_save()
	set_mission_completed()
	Flow.change_scene_to("menu")
	
func on_level_complete():
	print("Level complete!")
	update_surviving_characters()
	var index = levels.find(current_level_scene)
	
	transfer_chips_from_level()
	
	if index == len(levels) - 1:
		set_mission_completed()
	else:
		load_level(levels[index + 1])

