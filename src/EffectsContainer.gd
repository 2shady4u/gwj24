extends VBoxContainer

var cumulative_effects := {}

var _effect_label_resource := preload("res://src/EffectLabel.tscn")

func add_effects(upgrade : class_upgrade):
	var effects := upgrade.effects
	for key in effects.keys():
		if cumulative_effects.has(key):
			cumulative_effects[key] += effects[key]
		else:
			cumulative_effects[key] = effects[key]
	update_effects()

func remove_effects(upgrade : class_upgrade):
	var effects := upgrade.effects
	for key in effects.keys():
		if cumulative_effects.has(key):
			cumulative_effects[key] -= effects[key]
			if cumulative_effects[key] == 0.0:
				var _success := cumulative_effects.erase(key)
	update_effects()

func update_effects():
	for child in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(child)
		child.queue_free()

	for key in cumulative_effects.keys():
		var effect_label := _effect_label_resource.instance()
		$VBoxContainer.add_child(effect_label)

		effect_label.text = String(key) + ":" + String(cumulative_effects[key])
