extends AudioStreamPlayer2D

onready var audio_stream_random_pitch = AudioStreamRandomPitch.new()

var currently_playing = null

signal audio_finished

func _ready():
	# TODO can be expanded to have another audio stream instead? Which is not random
	# Maybe make different groups and settings for effects in the Effects node
	stream = audio_stream_random_pitch
	connect("finished", self, "_on_finished")
	
func _on_finished():
	emit_signal("audio_finished", self)

func is_available():
	return currently_playing == null
	
func play_effect(track_path: String, effect_position: Vector2 = Vector2(0, 0)):
	# TODO might not be always desired...
	if effect_position != null:
		position = effect_position
		
	var effect_audio_stream = load(track_path)
	effect_audio_stream.loop = false
	stream.audio_stream = effect_audio_stream
	currently_playing = track_path
	play()

func finish():
	currently_playing = null
	# TODO maybe clear audio track?
