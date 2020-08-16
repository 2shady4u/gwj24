tool
extends MarginContainer
class_name class_menu_tab

enum TABS {MAIN = 0, SETTINGS = 1, MISSION = 2, ORPHAN = 3}
export(TABS) var tab_type := TABS.MAIN setget set_tab_type

# warning-ignore:unused_signal
signal button_pressed(tab_type)

func _ready():
	set("custom_constants/margin_right", 32)
	set("custom_constants/margin_top", 32)
	set("custom_constants/margin_left", 32)
	set("custom_constants/margin_bottom", 32)

func set_tab_type(value : int):
	tab_type = value

func _on_quit_button_pressed():
	Flow.deferred_quit()

func update_tab():
	pass
