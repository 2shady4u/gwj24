extends Node2D
class_name Chip

onready var sprite: AnimatedSprite = $Sprite

export(String, "red", "blue", "yellow", "green", "purple", "cyan", "rainbow") var color = "red"
export(String) var identifier = "MDX-POW"


func _ready():
	set_color(color)


func set_type(type: String):
	match type:
		"HP":
			set_color("blue")
		"SPEED":
			set_color("green")
		"HEAL":
			set_color("cyan")
		"ATTACK":
			set_color("red")
		"DEFENSE":
			set_color("purple")
		"SPECIAL":
			set_color("rainbow")
		"ACTION":
			set_color("yellow")


func set_color(new_color: String):
	if not new_color in sprite.frames.get_animation_names():
		printerr("Color ", new_color, " is not possible for chip")
		return
	color = new_color
	sprite.animation = new_color


