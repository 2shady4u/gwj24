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
	"facility": "res://assets/music/facility.ogg",
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


func play_effect(track_path: String):
	play_positioned_effect(track_path, get_viewport().get_visible_rect().size / 2)

func play_positioned_effect(track_path: String, position: Vector2 = Vector2(0, 0)):
	effects.play_effect(track_path, position)

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


