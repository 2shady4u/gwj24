extends Control

onready var color_rect = $ColorRect
onready var title = $TabContainer/MainTab/VBoxContainer/TitleLabel
onready var tween = $Tween
onready var container = $TabContainer

signal finished

var type := "start"

func _ready():
	LevelFlow.text_overlay_UI = self
	
func start(text: String):
	type = "start"
	show()
	container.show()
	title.text = text
	color_rect.color = Color(0, 0, 0, 0.8)
	set_process(true)

func end(text: String):
	type = "end"
	show()
	container.show()
	title.text = text
	color_rect.color = Color(0, 0, 0, 0.8)
	set_process(true)

func fade_to_clear():
	container.hide()
	set_process(false)
	tween.interpolate_property(color_rect, "color", null, Color(0, 0, 0, 0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	print("Finished")
	hide()
	emit_signal("finished")

func fade_to_black():
	container.hide()
	set_process(false)
	tween.interpolate_property(color_rect, "color", null, Color(0, 0, 0, 1), 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	print("Finished")
	hide()
	emit_signal("finished")

	
func _process(_delta):
	if Input.is_action_just_pressed("confirm"):
		if type == "start":
			fade_to_clear()
		elif type == "end":
			fade_to_black()
		
