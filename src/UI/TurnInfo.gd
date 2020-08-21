extends HBoxContainer

onready var moves  = $Moves
onready var actions = $Actions
onready var healing_charges = $HealingCharges


var current_character: Character = null

func load_character(character: Character):
	if current_character:
		current_character.disconnect("updated_turn_info", self, "on_character_updated_turn_info")
	current_character = character
	current_character.connect("updated_turn_info", self, "on_character_updated_turn_info")

	moves.set_max_charges(current_character.stats.movement)
	moves.set_current_charges(current_character.stats.movement - current_character.moves_counter)
	actions.set_max_charges(current_character.stats.actions)
	actions.set_current_charges(current_character.stats.actions - current_character.action_counter)
	healing_charges.set_max_charges(current_character.stats.healing_charges)
	healing_charges.set_current_charges(current_character.healing_charges_left)

func on_character_updated_turn_info():
	moves.set_current_charges(current_character.stats.movement - current_character.moves_counter)
	actions.set_current_charges(current_character.stats.actions - current_character.action_counter)
	healing_charges.set_current_charges(current_character.healing_charges_left)

func _ready():
	pass
