extends Node


onready var SoundPlayer = preload("res://src/audio/SoundPlayer.tscn")


onready var sound_players = []

onready var sounds_playing = {}

func _ready():
	pass


func add_sound():
	var sound_player = SoundPlayer.instance()
	add_child(sound_player)

	sound_player.connect("finished", self, "_on_sound_finished")

	sound_players.append(sound_player)


func pause_sound(track_path):
	var sound_playing = sounds_playing.get(track_path)

	if sound_playing == null:
		return false
	elif sound_playing.paused:
		return false
	
	sound_playing.playback_position = sound_playing.player.get_playback_position()
	sound_playing.paused = true
	sound_playing.player.stop()
	return true

func unpause_sound(track_path) -> bool:
	var sound_playing = sounds_playing.get(track_path)

	if sound_playing == null:
		return false
	elif not sound_playing.paused:
		return false
	
	sound_playing.paused = false
	sound_playing.player.play(sound_playing.playback_position)
	return true

func _play_sound(sound_player, track_path: String, loop: bool = true):
	sound_player.play_sound(track_path, loop)
	sounds_playing[track_path] = {
		"player": sound_player,
		"paused": false,
		"properties": {
			"loop": loop,
		},
		"playback_position": 0.0,
	}
	
func play_sound(track_path: String, loop: bool = true):
	"""Currently, this will replay the song from the start on the same player"""
	var sound_playing = sounds_playing.get(track_path)
	if sound_playing != null:
		var sound_player = sound_playing.player
		_play_sound(sound_player, track_path, loop)
		return sound_player
	
	for sound_player in sound_players:
		if sound_player.is_available():
			_play_sound(sound_player, track_path, loop)

			return sound_player


func reset():
	for sound_player in sound_players:
		if sound_player.currently_playing != null:
			sound_player.stop()


func stop_sound(track_path: String):
	if track_path in sounds_playing:
		sounds_playing[track_path].player.stop()


func _on_sound_finished(sound_player: AudioStreamPlayer2D):
	if sound_player.currently_playing in sounds_playing:
		sounds_playing.erase(sound_player.currently_playing)
	sound_player.finish()