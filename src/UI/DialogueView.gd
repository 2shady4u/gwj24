extends Control


onready var portraits = {
	"fiston": preload("res://assets/graphics/portraits/biggie.png"), 
	"sonic": preload("res://assets/graphics/portraits/fast.png"), 
	"bebe": preload("res://assets/graphics/portraits/littleguy2.png"), 
	"sohn": preload("res://assets/graphics/portraits/regular.png"), 
	"sorella": preload("res://assets/graphics/portraits/sorella.png"), 
}

onready var text = $VBoxContainer/Underlayer/Text
onready var Speaker = $VBoxContainer/Underlayer/Speaker
onready var portrait = $VBoxContainer/Underlayer/Portrait

func _ready():
	pass
	
	
func set_conversation(speaker, text):
	# TODO only characters can speak now
	var name = Flow.get_orphan_value(speaker, "name", "NO NAME")
	portrait.set_text
