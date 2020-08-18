extends Node

onready var shader_rect = $Distortion

var shader_material : ShaderMaterial
var distortion_amount : float = 0.0

func _process(delta : float) -> void:
	if distortion_amount > 0.0:
		distortion_amount = clamp(distortion_amount - (delta * 3.0), 0.0, 2.0)
	shader_material.set_shader_param("distort_amount", distortion_amount)

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		distortion_amount = 1.5

func _ready() -> void:
	shader_material = shader_rect.material
