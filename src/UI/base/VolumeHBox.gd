tool
extends HBoxContainer

export(String) var text := "Master" setget set_text, get_text
func set_text(val : String) -> void:
	text = val
	if is_inside_tree():
		$Label.text = val
func get_text() -> String:
	return $Label.text

export(float) var value := 100.0 setget set_value, get_value
func set_value(val : float) -> void:
	value = val
	if is_inside_tree():
		$VolumeSlider.value = val
		$VolumeLabel.text = "%3d%%" % val
func get_value() -> float:
	return $VolumeSlider.value

func _ready():
	var _error : int = $VolumeSlider.connect("value_changed", self, "_on_value_changed")

func _on_value_changed(val : float):
	self.value = val
