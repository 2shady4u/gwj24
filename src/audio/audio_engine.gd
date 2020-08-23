"""
Audio Engine

Implemented:
	- Background music
	- Sound effects
	- Sounds for objects that generally make sounds

To implement:
	- Speech for conversations
"""
extends Node


const tracks = {
	"facility": "res://assets/music/facility.ogg",
	"finale": "res://assets/music/finale.ogg",
	"junkyard": "res://assets/music/junkyard.ogg",
	"sad": "res://assets/music/sad.ogg",
	"secret": "res://assets/music/secret.ogg",
	"sneaking": "res://assets/music/sneaking.ogg",
	"title": "res://assets/music/title.ogg",
	"upgrid": "res://assets/music/facility.ogg",
}

const sfx = {
	"ui_chip_in": "res://assets/audio/ui/chip_in.ogg",
	"ui_chip_out": "res://assets/audio/ui/chip_out.ogg",
	"ui_back": "res://assets/audio/ui/ui_back.ogg",
	"ui_back2": "res://assets/audio/ui/ui_back2.ogg",
	"ui_blocked": "res://assets/audio/ui/ui_blocked.ogg",
	"ui_confirm": "res://assets/audio/ui/ui_confirm.ogg",
	"ui_danger": "res://assets/audio/ui/ui_danger.ogg",
	"ui_move": "res://assets/audio/ui/ui_move.ogg",
	"ui_override": "res://assets/audio/ui/ui_override.ogg",
	"ui_select": "res://assets/audio/ui/ui_select.ogg",
	"heal": "res://assets/audio/heal.ogg",
	"move1": "res://assets/audio/move1.ogg",
	"move2": "res://assets/audio/move2.ogg",
}


onready var background_player: AudioStreamPlayer = get_node("BackgroundPlayer")
onready var speech_player: AudioStreamPlayer = get_node("SpeechPlayer")
onready var effects: Node = get_node("Effects")


func convert_scale_to_db(scale: float):
	return 20 * log(scale) / log(10)


var background_audio = null

export var MAX_SIMULTANEOUS_EFFECTS = 5


func _ready():
	#play_background_music("light_rain")
	for _i in range(MAX_SIMULTANEOUS_EFFECTS):
		effects.add_effect()


func play_effect(track_name: String):
	play_positioned_effect(tracks[track_name], get_viewport().get_visible_rect().size / 2)

func play_positioned_effect(effect_name: String, position: Vector2 = Vector2(0, 0)):
	effects.play_effect(sfx[effect_name], position)

func reset():
#	effects.reset()
	stop_background_music()

func play_background_music(track_path: String):
	"""Initiates a track to play as background music"""
	if background_audio != track_path:
		background_audio = track_path
		background_player.stream = load(track_path)
		background_player.play()

func stop_background_music():
	"""Stops the background music track"""
	if background_player.playing:
		background_player.stream()
		background_audio = null


