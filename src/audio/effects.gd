extends Node

# TODO merge effects and sounds to at least a base type they both vary from
onready var EffectPlayer = preload("res://src/audio/EffectPlayer.tscn")


onready var effect_players = []


onready var effects_playing = {}


func _ready():
	pass

func add_effect():
	var effect_player = EffectPlayer.instance()
	add_child(effect_player)

	effect_player.connect("audio_finished", self, "_on_effect_finished")

	effect_players.append(effect_player)

func play_effect(track_name: String):
	for effect_player in effect_players:
		if effect_player.is_available():
			effect_player.play_effect(track_name)
			effects_playing[track_name] = {
				"player": effect_player,
			}
			return

func _on_effect_finished(effect_player: AudioStreamPlayer):
	if effect_player.currently_playing in effects_playing:
		effects_playing.erase(effect_player.currently_playing)
	effect_player.finish()

