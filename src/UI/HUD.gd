extends Control


onready var turn_info = $TurnInfo
onready var name_label = $MarginContainer/PanelContainer/HBoxContainer/BioVBox/NameLabel

var current_character: Character = null

onready var _perks_hbox := $MarginContainer/PanelContainer/HBoxContainer/BioVBox/PerksHBox

onready var _attack_label := $MarginContainer/PanelContainer/HBoxContainer/StatsVBox/AttackHBox/AttackLabel
onready var _healing_label := $MarginContainer/PanelContainer/HBoxContainer/StatsVBox/HealingHBox/HealingLabel

var _perk_rect_resource := preload("res://src/UI/PerkRect.tscn")

const DEFAULT_ICON_TEXTURE := "res://assets/graphics/perks/dash.png"

func _ready():
	LevelFlow.connect("current_character_changed", self, "_on_current_character_changed")
	
func _on_current_character_changed(new_character: Character):
	print("Current character changed!")
	current_character = new_character
	turn_info.load_character(current_character)

	for child in _perks_hbox.get_children():
		_perks_hbox.remove_child(child)
		child.queue_free()

	var character_name := "MISSING NAME"
	var perk_ids := []
	var stats := {}
	if current_character.team == "PLAYER":
		var orphan_id : String = current_character.type
		character_name = Flow.get_orphan_value(orphan_id, "name", "MISSING NAME")

		perk_ids = Flow.get_orphan_value(orphan_id, "perk_ids", [])
		stats = current_character.get_stats()

	elif current_character.team == "ENEMY":
		var enemy_id : String = current_character.type
		character_name = Flow.get_enemy_value(enemy_id, "name", "MISSING NAME")

		perk_ids = Flow.get_enemy_value(enemy_id, "perk_ids", [])
		stats = current_character.get_stats()

	name_label.text = character_name
	for perk_id in perk_ids:
		var perk_rect := _perk_rect_resource.instance()
		_perks_hbox.add_child(perk_rect)

		var icon_texture : String = Flow.get_perk_value(perk_id, "icon_texture", DEFAULT_ICON_TEXTURE)
		perk_rect.texture = load(icon_texture)
	
	_attack_label.text = str(stats.get("damage", 0))
	_healing_label.text = str(stats.get("healing", 0))
	
