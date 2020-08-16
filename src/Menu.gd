extends Control

onready var _tab_container := $TabContainer

func _ready():
	
	State.add_upgrade_by_id("more_hp")
	State.add_upgrade_by_id("faster_speed_but_decreased_health")
	State.add_upgrade_by_id("more_hp")
	State.add_upgrade_by_id("more_hp")
	State.add_upgrade_by_id("more_hp")
	State.add_upgrade_by_id("more_hp")
	State.add_upgrade_by_id("more_hp")
	State.add_upgrade_by_id("more_hp")
	State.add_upgrade_by_id("more_hp")
	State.add_upgrade_by_id("more_hp")
	State.add_upgrade_by_id("more_hp")

	if ConfigData.skip_menu:
		if ConfigData.verbose_mode : print("Automatically skipping menu as requested by configuration data...")
		Flow.change_scene_to("game")
	else:
		_tab_container.set_current_tab(class_pause_tab.TABS.MAIN)
