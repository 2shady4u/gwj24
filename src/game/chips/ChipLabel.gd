extends Control

onready var name_label: Label = $Name
onready var sprite: AnimatedSprite = $Sprite
onready var tween: Tween = $Tween

func _ready():
	sprite.stop()
	
func set_chip(chip: Chip):
	name_label.text = chip.identifier
	sprite.animation = chip.color
	
func start_animation():
	tween.interpolate_property(self, "rect_position", null, rect_position + Vector2(0, -20), 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.8, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()
