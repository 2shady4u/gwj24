extends Node2D
class_name Character

onready var sprite: AnimatedSprite = $Sprite
onready var tween: Tween = $Tween
onready var healthbar = $HealthBar

export(String) var team 

var stats = {
	"health": {
		"current": 5,
		"max": 5,
	},
	"damage": 1,
	"healing": 1,
	"actions": 2,
	"movement": 4
}

var action_counter = 0
var moves_counter = 0
var last_action = "movement"

var upgrades = []

signal death(character)

func _ready():
	update_stats(stats)

func update_stats(new_stats):
	# TODO we're getting this out of state soon
	stats = new_stats
	healthbar.set_health(new_stats.health.max)
	healthbar.update_health(new_stats.health.current)

func shake(shake_size: Vector2):
	var original_position = position
	tween.interpolate_property(self, "position", null, position + shake_size, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	tween.interpolate_property(self, "position", null, original_position, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)

func heal_up(points: int, direction: Vector2):
	stats.health.current = min(stats.health.current + points, stats.health.max)
	print("Healed up!")
	shake(direction / 4)
	healthbar.update_health(stats.health.current)

func take_damage(points: int, direction: Vector2):
	stats.health.current = max(stats.health.current - points, 0)
	if stats.health.current == 0:
		print("I died!")
		self.queue_free()
		emit_signal("death", self)
	else:
		shake(direction / 2)
	healthbar.update_health(stats.health.current)

func perform_action():
	action_counter += 1
	last_action = "action"

func move():
	if moves_counter == stats.movement:
		moves_counter = 0

	if moves_counter == 0:
		action_counter += 1
	moves_counter += 1
	
	last_action = "movement"

func turn_finished():
	if last_action == "finish":
		return true
	if last_action == "action":
		return action_counter >= stats.actions
	elif last_action == "movement":
		if action_counter >= stats.actions:
			return moves_counter >= stats.movement
		return false

func finish_turn():
	last_action = "finish"

func can_perform_action():
	if action_counter < stats.actions:
		return true

func reset_turn():
	moves_counter = 0
	action_counter = 0