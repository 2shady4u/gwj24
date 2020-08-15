extends MarginContainer
class_name class_pause_tab

enum TABS {MAIN = 0, SETTINGS = 1}
export(TABS) var tab_type := TABS.MAIN setget set_tab_type

signal button_pressed(tab_type)

func set_tab_type(value : int):
	tab_type = value

func _on_back_button_pressed():
	emit_signal("button_pressed", TABS.MAIN)

func _on_quit_button_pressed():
	Flow.deferred_quit()

func update_tab():
	pass
