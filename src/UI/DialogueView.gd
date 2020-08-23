extends Control

onready var text_label = $VBoxContainer/Underlayer/Text
onready var speaker_label = $VBoxContainer/Underlayer/Speaker
onready var portrait_texture = $VBoxContainer/Underlayer/Portrait
onready var timer: Timer = $Timer


signal finished

func _ready():
	pass

func set_conversation(speaker_id, text):
	# TODO only characters can speak now
	var portrait = Flow.get_orphan_value(speaker_id, "portrait_texture", "")
	var name = Flow.get_orphan_value(speaker_id, "name", "NO NAME")
	portrait_texture.texture = load(portrait)
	speaker_label.text = name
	text_label.text = text
	show()
	set_process(true)


func end():
	set_process(false)
	timer.start(0.1)
	yield(timer, "timeout")
	hide()
	emit_signal("finished")


func _process(_delta):
	if Input.is_action_just_pressed("confirm"):
		end()
