extends Node2D
class_name Level

export var intro_text = ""
export var outro_text = ""

onready var entities: YSort = $Entities
onready var camera: Camera2D = $Camera
onready var tween: Tween = $Tween
onready var tiles = $Tiles/Tiles
onready var chip_label = $ChipLabel
onready var healing_particles = $HealingParticles
onready var distortion = $Distortion

onready var chip_scene = preload("res://src/game/chips/Chip.tscn")

var current_character : Character = null
var astar: AStar2D = AStar2D.new()
var astar_id_map = {}

const directions = {
	"UP": Vector2(0, -16),
	"DOWN": Vector2(0, 16),
	"RIGHT": Vector2(16, 0),
	"LEFT": Vector2(-16, 0),
}

signal complete
signal failed
signal chip_pickup

func characters():
	return get_tree().get_nodes_in_group("characters")
	
func chips():
	return get_tree().get_nodes_in_group("chips")
	

func events():
	return get_tree().get_nodes_in_group("events")

func _ready():
	# opens up the camera to be used for the characters
	remove_child(camera)
	switch_character(characters()[0])
	snap_characters()
	snap_chips()
	snap_events()
	
	var used_tiles = tiles.get_used_cells()
	var tile_mapping = {}
	var i = 0
	for used_tile in used_tiles:
		var world_position = tiles.map_to_world(used_tile)
		if get_tile(world_position) == "floor":
			tile_mapping[used_tile] = i
			astar.add_point(i, get_snapped_position_in_grid(world_position))
			astar_id_map[get_snapped_position_in_grid(world_position)] = i
			for added_point in tile_mapping.keys():
				if used_tile.distance_to(added_point) == 1:
					astar.connect_points(tile_mapping[added_point], i)
			i += 1

			
	for character in characters():
		character.connect("death", self, "on_character_death")
		
	set_process(false)
	
func start():
	set_process(true)

func get_snapped_position_in_grid(position_to_snap: Vector2):
	return Vector2(floor(position_to_snap.x / 16) * 16 + 8, floor(position_to_snap.y / 16) * 16 + 8)


func snap_events():
	for event in events():
		var current_position = event.position
		event.position =get_snapped_position_in_grid(current_position)
		print("set character on ", event.position, " from ", current_position)
		
func snap_chips():
	for chip in chips():
		var current_position = chip.position
		chip.position =get_snapped_position_in_grid(current_position)
		print("set character on ", chip.position, " from ", current_position)
		
func snap_characters():
	for character in characters():
		var current_position = character.position
		character.position =get_snapped_position_in_grid(current_position)
		print("set character on ", character.position, " from ", current_position)

func switch_character(new_character: Character):
	snap_characters()
	if current_character:
		print("Switching from ", current_character, current_character.name, " to ", new_character, new_character.name)
		tween.stop_all()
		camera.position = Vector2(0, 0)
		set_process(false)
		
		# add_child(camera)
		camera.smoothing_enabled = false
		tween.interpolate_property(camera, "position", null, new_character.position - current_character.position, 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween, "tween_completed")
		current_character.remove_child(camera)

	current_character = new_character
	camera.position = Vector2(0, 0)
	current_character.add_child(camera)
	camera.smoothing_enabled = true
	current_character.reset_turn()
	print("Using the current character setter!")
	LevelFlow.current_character = current_character

	set_process(true)

func get_tile(level_position: Vector2):
	var tile_position = tiles.world_to_map(level_position)
	var tile_id = tiles.get_cellv(tile_position)
	return tiles.tile_set.tile_get_name(tile_id)
	
func move_character(character, location: Vector2):
	tween.stop_all()
	set_process(false)
	var transition_time = 0.15
	tween.interpolate_property(character, "position", character.position, location, transition_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	
	if character.team == "PLAYER":
		var events = get_events(location)
		for event in events:
			if event is DialogueEvent:
				print("Stepped on event")
				LevelFlow.dialogue_overlay_UI.set_conversation(event.speaker, event.text)
				yield(LevelFlow.dialogue_overlay_UI, "finished")

		var picked_up_chips = []
		for chip in chips():
			if chip.position == location:
				picked_up_chips.append(chip)
		for picked_up_chip in picked_up_chips:
			yield(pickup_chip(picked_up_chip), "completed")
	set_process(true)
	

func move_action(character: Character, direction: Vector2):
	var new_position = get_snapped_position_in_grid(character.position + direction)
	if get_tile(new_position) == "floor":
		for other_character in characters():
			if other_character == character:
				continue
			if get_snapped_position_in_grid(other_character.position) == new_position:
				if character.can_perform_action():
					yield(bump(character, other_character), "completed")
				else:
					yield(character.shake(direction / 8), "completed")
				return
		character.move()
		yield(move_character(character, new_position), "completed")
	else:
		yield(character.shake(direction / 8), "completed")
		

func pickup_chip(chip: Chip):
	chip_label.set_chip(chip)
	emit_signal("chip_pickup", chip.identifier)
	chip_label.rect_position = chip.position - Vector2(20, 16)
	chip.queue_free()
	chip_label.show()
	yield(chip_label.start_animation(), "completed")


func bump(character: Character, other_character: Character):
	tween.stop_all()
	set_process(false)
	var transition_time = 0.2
	var original_position = character.position
	var direction = (other_character.position - character.position) / 2
	var halfway_position = (other_character.position + character.position) / 2 + direction / 2

	tween.interpolate_property(character, "position", null, halfway_position, transition_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	
	if other_character.team == character.team and other_character.current_health < other_character.stats.health:
		other_character.heal_up(character.stats.healing, direction)
		play_healing(other_character.position)
		character.perform_action()
	elif other_character.team != character.team:
		other_character.take_damage(character.stats.damage, direction)
		if other_character.team == "PLAYER":
			play_damage(other_character.position)
		character.perform_action()
	
	tween.interpolate_property(character, "position", null, original_position, transition_time / 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	set_process(true)
	
func play_damage(damage_position: Vector2):
	distortion.position = damage_position
	distortion.visible = true
	yield(get_tree().create_timer(0.2), "timeout")
	distortion.visible = false
	
	
func play_healing(healing_position: Vector2):
	healing_particles.position = healing_position - Vector2(0, 4)
	healing_particles.emitting = true

func _process(_delta):
	if Input.is_action_just_pressed("switch"):
		print("Switch pressed!")
		var characters = characters()
		for character in characters:
			print(character.name)
		print("These are the characters ", characters)
		var index = characters.find(current_character)
		switch_character(characters[(index + 1) % characters.size()])
		
	if current_character.team != "PLAYER":
		yield(ai_decision(), "completed")
		validate_turn()
	else:
		if Input.is_action_just_pressed("move_up"):
			yield(move_action(current_character, directions.UP), "completed")
			validate_turn()
		if Input.is_action_just_pressed("move_down"):
			yield(move_action(current_character, directions.DOWN), "completed")
			validate_turn()
		if Input.is_action_just_pressed("move_left"):
			current_character.sprite.flip_h = true
			yield(move_action(current_character, directions.LEFT), "completed")
			validate_turn()
		if Input.is_action_just_pressed("move_right"):
			current_character.sprite.flip_h = false
			yield(move_action(current_character, directions.RIGHT), "completed")
			validate_turn()
		if Input.is_action_just_pressed("interact"):
			level_complete()
		if Input.is_action_just_pressed("toggle_inventory"):
			level_failed()
			
func level_complete():
	emit_signal("complete")
	
func level_failed():
	emit_signal("failed")

func get_events(event_position: Vector2):
	var triggered_events = []
	for event in events():
		if event.position == event_position:
			triggered_events.append(event)
	return triggered_events
			
func ai_decision():
	# can't wait for this hacked together mess
	snap_characters()
	var player_characters = get_player_characters()
	var paths = []
	for player_character in player_characters:
		var current_position: int = astar_id_map[current_character.position]
		var other_position: int = astar_id_map[player_character.position]
		paths.append(astar.get_point_path(current_position, other_position))
	var min_size = 999
	var min_path = null
	for path in paths:
		if path.size() < min_size:
			min_size = path.size()
			min_path = path
		elif path.size() == min_size:
			# TODO add weight on who to attack
			pass
	if min_path:
		if min_path.size() == 2:
			if not current_character.can_perform_action():
				current_character.finish_turn()
				set_process(false)
				return yield(get_tree().create_timer(0.1), "timeout")
		var point_to_travel = min_path[1]
		yield(move_action(current_character, point_to_travel - current_character.position), "completed")
		set_process(false)
		yield(get_tree().create_timer(0.1), "timeout")
		set_process(true)
	else:
		yield(get_tree().create_timer(0.1), "timeout")
		print("This should never happen!!! So it's okay if it crashes here.")
		
		
func filter_characters_team(team: String):
	var all_characters = characters()
	var filtered = []
	for character in all_characters:
		if character.team == team and not character.is_queued_for_deletion(): 
			filtered.append(character)
	return filtered

func get_player_characters():
	return filter_characters_team("PLAYER")

func get_enemy_characters():
	return filter_characters_team("ENEMY")

func character_turns():
	# TODO make turn order respectively in here
	return characters()

func validate_turn():
	print(current_character.turn_finished())
	if current_character.turn_finished():
		var character_turns = character_turns()
		var index = character_turns.find(current_character)
		var new_character = character_turns[(index + 1) % character_turns.size()]
		print("Switching to ", new_character, new_character.name)
		switch_character(new_character)
	check_level_complete()


func get_drop(drops):
	var dropped = []
	for drop in drops:
		if randf() < drops[drop]:
			dropped.append(drop)
	
	if len(dropped) > 0:
		var rarest_drop = null
		var lowest_rarity = 1.0
		for drop in dropped:
			if drops[drop] < lowest_rarity:
				rarest_drop = drop
				lowest_rarity = drops[drop]
		return rarest_drop
	return null


func spawn_drop(drop: String, drop_position: Vector2):
	var chip = chip_scene.instance()
	var chip_type = Flow.get_upgrade_value(drop, "type", "HP")
	var chip_name = Flow.get_upgrade_value(drop, "name", "NONE")

	entities.add_child(chip)
	chip.position = get_snapped_position_in_grid(drop_position)
	chip.identifier = chip_name
	chip.set_type(chip_type)


func on_character_death(character: Character):
	if character.team == "ENEMY":
		print_debug("Enemy dieded!")
		var drops = Flow.get_enemy_value(character.type, "drops", {})
		var drop = get_drop(drops)
		if drop:
			spawn_drop(drop, character.position)
	elif character.team == "PLAYER":
		print_debug("Player character dieded!")


func check_level_complete():
	var player_characters = get_player_characters()
	var enemy_characters = get_enemy_characters()

	if len(player_characters) == 0:
		emit_signal("failed")
	
	# TODO should replace this with the door...
	if len(enemy_characters) == 0:
		print("END END END")
		emit_signal("complete")
		
