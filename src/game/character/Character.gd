extends Node2D
class_name Character

onready var sprite: AnimatedSprite = $Sprite
onready var tween: Tween = $Tween
onready var healthbar = $HealthBar

export(String, "PLAYER", "ENEMY", "OBSTACLE", "PET", "ALLY", "NONE") var team = "PLAYER"
export(String) var type


# traditional mode
# var GAME_SYSTEM = "traditional"
# this is with the new style where actions and movement is separated
var GAME_SYSTEM = "rework"

var stats = {
}

var _current_health := 0
var current_health : int setget set_current_health, get_current_health
func set_current_health(value: int):
	print("Setting current health!")
	_current_health = value
	healthbar.update_health(_current_health)
func get_current_health() -> int:
	return _current_health

var action_counter = 0
var moves_counter = 0
var healing_charges_left = 0
var last_action = "movement"

var upgrades = []

signal death(character)
signal updated_turn_info

func _ready():
	if team != "PLAYER" and team != "ENEMY" and team != "ALLY":
		healthbar.hide()
	else:
		update_stats(get_stats().duplicate(true))
	
func get_stats():
	print("Getting stats for ", type, " of group ", team)
	if team == "PLAYER":
		return State.get_orphan_by_id(type).get_stats()
	elif team == "ALLY":
		return Flow.get_ally_value(type, "base_stats", {
			"health": 4,
			"damage": 1,
			"healing": 1,
			"healing_charges": 2,
			"actions": 2,
			"movement": 4
		})
	elif team == "ENEMY":
		return Flow.get_enemy_value(type, "base_stats", {
			"health": 4,
			"damage": 1,
			"healing": 1,
			"healing_charges": 2,
			"actions": 2,
			"movement": 4
		})
	

func update_stats(new_stats):
	# TODO we're getting this out of state soon
	stats = new_stats
	healthbar.set_health(stats.health)
	if GAME_SYSTEM == "rework":
		stats.actions -= 1
	self.current_health = stats.health
	healing_charges_left = stats.healing_charges

func shake(shake_size: Vector2):
	var original_position = position
	tween.interpolate_property(self, "position", null, position + shake_size, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	tween.interpolate_property(self, "position", null, original_position, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")

func move_in(direction: Vector2):
	print("Moving in ", direction)
	tween.interpolate_property(self, "position", null, position + direction, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")


func heal_up(points: int, direction: Vector2):
	AudioEngine.play_effect("heal")
	self.current_health = min(self.current_health + points, stats.health)
	shake(direction / 4)

func take_damage(points: int):
	var perks = get_perks()
	if "armor" in perks:
		points = int(ceil(float(points) / 2))

	self.current_health = max(self.current_health - points, 0)
	if self.current_health == 0:
		AudioEngine.play_effect("explode")
		print("I died!")
		self.queue_free()
		emit_signal("death", self)
	else:
		if team == "PLAYER":
			AudioEngine.play_effect("glitch")
		else:
			AudioEngine.play_effect("enemy_hit")
		
	
func get_perks():
	var perks = []
	if team == "PLAYER":
		perks = Flow.get_orphan_value(type, "perk_ids", [])
	elif team == "PLAYER":
		perks = Flow.get_enemy_value(type, "perk_ids", [])
	return perks

func recharge():
	moves_counter = max(0, moves_counter - 1)
	action_counter = max(0, action_counter - 1)
	emit_signal("updated_turn_info")

func perform_heal():
	healing_charges_left = max(0, healing_charges_left - 1)

func perform_action():
	action_counter += 1
	last_action = "action"
	emit_signal("updated_turn_info")

func can_move():
	if GAME_SYSTEM == "rework":
		return moves_counter < stats.movement 
	return true

func move():
	if GAME_SYSTEM == "traditional":
		if moves_counter == stats.movement:
			moves_counter = 0

		if moves_counter == 0:
			action_counter += 1

	moves_counter += 1
	
	last_action = "movement"
	emit_signal("updated_turn_info")

func turn_finished():
	if last_action == "finish":
		return true

	if GAME_SYSTEM == "traditional":
		if last_action == "action":
			return action_counter >= stats.actions
		elif last_action == "movement":
			if action_counter >= stats.actions:
				return moves_counter >= stats.movement
			return false
	elif GAME_SYSTEM == "rework":
		if last_action == "action":
			return action_counter >= stats.actions
		elif last_action == "movement":
			if action_counter >= stats.actions:
				return moves_counter >= stats.movement
			return false

func can_heal():
	return healing_charges_left > 0

func finish_turn():
	last_action = "finish"

func can_perform_action():
	if action_counter < stats.actions:
		return true
	return false

func reset_turn():
	last_action = "none"
	moves_counter = 0
	action_counter = 0
	var perks = get_perks()
	if "healer" in perks:
		healing_charges_left = stats.healing_charges
	emit_signal("updated_turn_info")
