extends Node2D


onready var camera: Camera2D = $Camera
onready var tween: Tween = $Tween
onready var tiles = $Tiles/Tiles
onready var chip_label = $ChipLabel

var current_character : Character = null

const directions = {
	"UP": Vector2(0, -16),
	"DOWN": Vector2(0, 16),
	"RIGHT": Vector2(16, 0),
	"LEFT": Vector2(-16, 0),
}

func characters():
	return get_tree().get_nodes_in_group("characters")
	
func chips():
	return get_tree().get_nodes_in_group("chips")

func _ready():
	# opens up the camera to be used for the characters
	remove_child(camera)
	switch_character(characters()[0])
	snap_characters()
	snap_chips()
	
	for character in characters():
		character.connect("death", self, "on_character_death")

func get_snapped_position_in_grid(position_to_snap: Vector2):
	return Vector2(floor(position_to_snap.x / 16) * 16 + 8, floor(position_to_snap.y / 16) * 16 + 8)

func snap_chips():
	print("There are this many chips ", chips())
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
	if current_character:
		current_character.remove_child(camera)
	current_character = new_character
	current_character.add_child(camera)
	get_tile(current_character.position)

func get_tile(level_position: Vector2):
	var tile_position = tiles.world_to_map(level_position)
	var tile_id = tiles.get_cellv(tile_position)
	print(tiles.tile_set.tile_get_name(tile_id))
	return tiles.tile_set.tile_get_name(tile_id)

func move_character(character: Character, direction: Vector2):
	var new_position = get_snapped_position_in_grid(character.position + direction)
	if get_tile(new_position) == "floor":
		for other_character in characters():
			if other_character == character:
				continue
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
		for chip in chips():
			if chip.position == new_position:
				pickup_chip(chip)
		set_process(true)

func pickup_chip(chip: Chip):
	chip_label.set_chip(chip)
	chip_label.rect_position = chip.position - Vector2(20, 16)
	chip_label.start_animation()
	chip_label.show()
	chip.queue_free()
		

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
		var characters = characters()
		for character in characters:
			print(character.name)
		print("These are the characters ", characters)
		var index = characters.find(current_character)
		switch_character(characters[(index + 1) % characters.size()])
	if Input.is_action_just_pressed("move_up"):
		move_character(current_character, directions.UP)
	if Input.is_action_just_pressed("move_down"):
		move_character(current_character, directions.DOWN)
	if Input.is_action_just_pressed("move_left"):
		move_character(current_character, directions.LEFT)
		current_character.sprite.flip_h = true
	if Input.is_action_just_pressed("move_right"):
		move_character(current_character, directions.RIGHT)
		current_character.sprite.flip_h = false
