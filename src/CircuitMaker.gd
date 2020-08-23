extends Control

onready var texture_rect = $TextureRect

const EIGHT_DIRECTIONS : Array = [
	Vector2(-1, -1),
	Vector2(0, -1),
	Vector2(1, -1),
	Vector2(-1, 0),
	Vector2(1, 0),
	Vector2(-1, 1),
	Vector2(0, 1),
	Vector2(1, 1)
]

func process_pixel(circuit : Image, pos : Vector2, current_colour : Color, path_colour : Color) -> void:
	var next_colour : Color = current_colour
	next_colour.r = clamp(next_colour.r - 0.01, 0.0, 1.0)
	next_colour.g = clamp(next_colour.g - 0.01, 0.0, 1.0)
	next_colour.b = clamp(next_colour.b - 0.01, 0.0, 1.0)
	pos = Vector2(
		wrapf(pos.x, 0, 256),
		wrapf(pos.y, 0, 256)
	)
	circuit.set_pixelv(pos, next_colour)
	# If the "signal" has run out of power, don't continue
	if next_colour.v <= 0.0:
		return
	# Spread 'em!
	for offset in EIGHT_DIRECTIONS:
		if circuit.get_pixelv(pos + offset) == path_colour:
			process_pixel(circuit, pos + offset, next_colour, path_colour)

func process_lines_of_colour(circuit : Image, path_colour : Color, colour_to_set : Color) -> void:
	for x in range(0, circuit.get_size().x):
		for y in range(0, circuit.get_size().y):
			if circuit.get_pixel(x, y) == colour_to_set:
				process_pixel(circuit, Vector2(x, y), colour_to_set, path_colour)

func process_image(circuit) -> void:
	print("00% done")
	process_lines_of_colour(circuit, Color("4fac8e"), Color(1.0, 0.0, 0.0))
	print("30% done")
	process_lines_of_colour(circuit, Color("b6e7d3"), Color(0.0, 1.0, 0.0))
	print("60% done")
	process_lines_of_colour(circuit, Color("357673"), Color(0.0, 0.0, 1.0))

func _ready() -> void:
	var texture : Texture = load("res://assets/graphics/circuit_shader.png")
	var image : Image = texture.get_data()
	image.lock()
	process_image(image)
	image.unlock()
	var new_texture : ImageTexture = ImageTexture.new()
	new_texture.create_from_image(image)
	texture_rect.texture = new_texture
	
