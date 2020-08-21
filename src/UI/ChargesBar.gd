extends HBoxContainer


export(String, "action", "moves", "healing_charges") var type = "action"

onready var sprite_sizes = {
	"start": Vector2(32, 32),
	"segment": Vector2(8, 14),
	"end": Vector2(16, 16),
}

var start_charge = null
var end_charge =  null
var segments_in_between = []

var active_charges = 0
# TODO note that currently it's not really supported to have just 1 charge for something

onready var sprites = {
	"action": {
		"start": {
			"filled": preload("res://assets/graphics/ui/energy_ui_start.png"),
			"empty": preload("res://assets/graphics/ui/energy_ui_start_empty.png"),
		},
		"segment": {
			"filled": preload("res://assets/graphics/ui/energy_ui_segment.png"),
			"empty": preload("res://assets/graphics/ui/battle_ui_segment_empty.png"),
		},
		"end": {
			"filled": preload("res://assets/graphics/ui/energy_ui_end.png"),
			"empty": preload("res://assets/graphics/ui/battle_ui_end_empty.png"),
		}
	}, 
	"moves": {
		"start": {
			"filled": preload("res://assets/graphics/ui/move_ui_start.png"),
			"empty": preload("res://assets/graphics/ui/move_ui_start_empty.png"),
		},
		"segment": {
			"filled": preload("res://assets/graphics/ui/move_ui_segment.png"),
			"empty": preload("res://assets/graphics/ui/battle_ui_segment_empty.png"),
		},
		"end": {
			"filled": preload("res://assets/graphics/ui/move_ui_end.png"),
			"empty": preload("res://assets/graphics/ui/battle_ui_end_empty.png"),
		}
	}, 
	"healing_charges": {
		"start": {
			"filled": preload("res://assets/graphics/ui/heal_ui_start.png"),
			"empty": preload("res://assets/graphics/ui/heal_ui_start_empty.png"),
		},
		"segment": {
			"filled": preload("res://assets/graphics/ui/heal_ui_segment.png"),
			"empty": preload("res://assets/graphics/ui/battle_ui_segment_empty.png"),
		},
		"end": {
			"filled": preload("res://assets/graphics/ui/heal_ui_end.png"),
			"empty": preload("res://assets/graphics/ui/battle_ui_end_empty.png"),
		}
	}
}

func _ready():
	for child in get_children():
		remove_child(child)
		child.queue_free()
	start_charge = TextureRect.new()
	start_charge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	start_charge.rect_min_size = sprite_sizes.start * 2
	start_charge.texture = sprites[type].start.filled
	add_child(start_charge)
	
	end_charge = TextureRect.new()
	end_charge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	end_charge.rect_min_size = sprite_sizes.end * 2
	end_charge.texture = sprites[type].end.filled
	add_child(end_charge)
	
	
func set_max_charges(max_charges: int):
	print("Setting max charges to ", max_charges)
	var number_of_segments = max_charges - 2
	if len(segments_in_between) < number_of_segments:
		# need to make more segments
		for _i in range(number_of_segments - len(segments_in_between)):
			var segment = TextureRect.new()
			segment.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			segment.rect_min_size = sprite_sizes.segment * 2
			segment.texture = sprites[type].segment.filled
			add_child(segment)
			segments_in_between.append(segment)
	else:
		# need to remove some segments
		var deleted_segments = []
		for i in range(len(segments_in_between) - number_of_segments):
			deleted_segments.append(segments_in_between[i])
		for deleted_segment in deleted_segments:
			segments_in_between.erase(deleted_segment)
			remove_child(deleted_segment)
			deleted_segment.queue_free()
	
	move_child(end_charge, max_charges)
	set_current_charges(active_charges)


func set_start_texture(charged: bool):
	if charged:
		start_charge.texture = sprites[type].start.filled
	else:
		start_charge.texture = sprites[type].start.empty
	

func set_segment_texture(segment_index: int, charged: bool):
	if charged:
		segments_in_between[segment_index].texture = sprites[type].segment.filled
	else:
		segments_in_between[segment_index].texture = sprites[type].segment.empty


func set_end_texture(charged: bool):
	if charged:
		end_charge.texture = sprites[type].end.filled
	else:
		end_charge.texture = sprites[type].end.empty
		

func set_current_charges(current_charges: int):
	active_charges = current_charges
	for i in range(2 + len(segments_in_between)):
		var segment_is_charged: bool = current_charges > i
		# start segment
		if i == 0:
			set_start_texture(segment_is_charged)
		# final segment
		elif i == 2 + len(segments_in_between) - 1:
			set_end_texture(segment_is_charged)
		# segment in between
		else:
			set_segment_texture(i - 1, segment_is_charged)

# for testing the component
#func _process(_delta):
#	if Input.is_action_just_pressed("move_up"):
#		set_max_charges(2 + len(segments_in_between) + 1)
#	if Input.is_action_just_pressed("move_down"):
#		set_max_charges(2 + len(segments_in_between) - 1)
#	if Input.is_action_just_pressed("move_left"):
#		set_current_charges(active_charges - 1)
#	if Input.is_action_just_pressed("move_right"):
#		set_current_charges(active_charges + 1)
