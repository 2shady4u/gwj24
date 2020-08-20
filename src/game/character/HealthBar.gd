extends Node2D

export var segments_per_row = 5

onready var left_texture = preload("res://assets/graphics/ui/HP_bar_end_left-export.png")
onready var middle_texture = preload("res://assets/graphics/ui/HP_bar_segment-export.png")
onready var right_texture = preload("res://assets/graphics/ui/HP_bar_end_right-export.png")

var segments = []

var gray = Color(0.4, 0.4, 0.4)

func _ready():
	set_health(12)
	
func set_health(health: int):
	for segment in segments:
		segment.queue_free()
	segments = []
	var y_offset = -2 * int(health / segments_per_row)
	var pointer = Vector2(0, y_offset)
	for i in range(int(health / segments_per_row) + 1):
		var remaining_health = min(health - i * segments_per_row, segments_per_row)
		var x_offset =- 3 * (remaining_health - 1) / 2 - 4
		pointer.x = x_offset
		for j in range(remaining_health):
			var increment = 3
			var sprite
			if j == 0 and remaining_health == 1:
				sprite = make_sprite(middle_texture)
			elif j == 0:
				sprite = make_sprite(left_texture)
			elif j == remaining_health - 1:
				sprite = make_sprite(right_texture)
				increment += 0
			else:
				sprite = make_sprite(middle_texture)
			pointer.x += increment
			sprite.position = pointer
			segments.append(sprite)
		pointer.y += 4

func make_sprite(texture: Texture):
	var sprite = Sprite.new()
	add_child(sprite)
	sprite.texture = texture
	return sprite
			
	
func update_health(health: int):
	for i in range(segments.size()):
		var segment = segments[i]
		if i > health - 1:
			segment.modulate = gray
		else:
			segment.modulate = Color(1, 1, 1, 1)
