extends Node2D
class_name Character

onready var sprite: AnimatedSprite = $Sprite
onready var tween: Tween = $Tween

export(String) var team 

var stats = {
	"health": {
		"current": 5,
		"max": 5,
	},
	"damage": 1,
	"healing": 1,
}

var upgrades = []

signal death(character)

func _ready():
	pass # Replace with function body.


func shake(shake_size: Vector2):
	var original_position = position
	tween.interpolate_property(self, "position", null, position + shake_size, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	tween.interpolate_property(self, "position", null, original_position, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)

func heal_up(points: int, direction: Vector2):
	stats.health.current = min(stats.health.current + points, stats.health.max)
	print("Healed up!")
	shake(direction / 4)

func take_damage(points: int, direction: Vector2):
	stats.health.current = max(stats.health.current - points, 0)
	if stats.health.current == 0:
		print("I died!")
		self.queue_free()
		emit_signal("death", self)
	else:
		shake(direction / 2)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
