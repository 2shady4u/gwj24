extends Node2D

onready var characters: Array = $Characters.get_children()
onready var camera: Camera2D = $Camera
onready var tween: Tween = $Tween
onready var tiles = $Tiles/Tiles

var current_character : Character = null

const directions = {
	"UP": Vector2(0, -16),
	"DOWN": Vector2(0, 16),
	"RIGHT": Vector2(16, 0),
	"LEFT": Vector2(-16, 0),
}

func _ready():
	# opens up the camera to be used for the characters
	remove_child(camera)
	switch_character(characters[0])
	snap_characters()
	
	for character in characters:
		character.connect("death", self, "on_character_death")

func get_snapped_position_in_grid(position_to_snap: Vector2):
	return Vector2(int(position_to_snap.x / 16) * 16 + 8, int(position_to_snap.y / 16) * 16 + 8)

func snap_characters():
	for character in characters:
		var current_position = character.position
		character.position =get_snapped_position_in_grid(current_position)
		print("set character on ", character.position, " from ", current_position)

func switch_character(new_character: Character):
	if current_character:
		current_character.remove_child(camera)
	current_character = new_character
	current_character.add_child(camera)
	get_tile(current_character.position)

func get_tile(level_position: Vector2):
	var tile_position = tiles.world_to_map(level_position)
	var tile_id = tiles.get_cellv(tile_position)
	return tiles.tile_set.tile_get_name(tile_id)

func move_character(character: Character, direction: Vector2):
	var new_position = get_snapped_position_in_grid(character.position + direction)
	if get_tile(new_position) == "floor":
		for other_character in characters:
			if get_snapped_position_in_grid(other_character.position) == new_position:
				bump(character, other_character)
				return
		tween.stop_all()
		set_process(false)
		var transition_time = 0.2
		tween.interpolate_property(character, "position", character.position, new_position, transition_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
		# we don't await the tween time because the easing makes it seem longer, thus you may try inputting sooner than the easing takes place. Additionally, with the cubic 
		yield(get_tree().create_timer(max(0, transition_time - 0.1)), "timeout")
		set_process(true)

func bump(character: Character, other_character: Character):
	tween.stop_all()
	set_process(false)
	var transition_time = 0.2
	var original_position = character.position
	var original_other_position = other_character.position
	var direction = (other_character.position - character.position) / 2
	var halfway_position = (other_character.position + character.position) / 2 + direction / 2

	tween.interpolate_property(character, "position", null, halfway_position, transition_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	
	if other_character.team == character.team:
		other_character.heal_up(character.stats.healing, direction)
	else:
		other_character.take_damage(character.stats.damage, direction)
	
	tween.interpolate_property(character, "position", null, original_position, transition_time / 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("switch"):
		print("Switch pressed!")
		var index = characters.find(current_character)
		switch_character(characters[(index + 1) % characters.size()])
	if Input.is_action_just_pressed("move_up"):
		move_character(current_character, directions.UP)
	if Input.is_action_just_pressed("move_down"):
		move_character(current_character, directions.DOWN)
	if Input.is_action_just_pressed("move_left"):
		move_character(current_character, directions.LEFT)
	if Input.is_action_just_pressed("move_right"):
		move_character(current_character, directions.RIGHT)

func on_character_death(character: Character):
	characters = []
	for character in $Characters.get_children():
		if character.stats.health.current > 0:
			characters.append(character)
