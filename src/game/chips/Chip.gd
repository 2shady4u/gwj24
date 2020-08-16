extends Node2D
class_name Chip

onready var sprite: AnimatedSprite = $Sprite

export(String, "red", "blue", "yellow", "green", "purple", "cyan", "rainbow") var color = "red"
export(String) var identifier = "MDX-POW"


func _ready():
	set_color(color)


func set_color(color: String):
	if not color in sprite.frames.get_animation_names():
		printerr("Color ", color, " is not possible for chip")
		return
	sprite.animation = color
