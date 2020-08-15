extends Node

## AUDIO SETTINGS ##############################################################
var master_volume := 100.0 setget set_master_volume

var music_volume := 100.0 setget set_music_volume
var mute_music := false setget set_mute_music

var sfx_volume := 100.0 setget set_sfx_volume
var mute_sfx := false setget set_mute_sfx

## COMMON CONFIG #################################################################
var skip_menu := false
var verbose_mode := true

func set_master_volume(value : float):
	master_volume = value
	var volume_db : float = 20*log(float(value)/100.0)/log(10.0)
	# -INF (when new_value = 0) doesn't seem to pose any issues!
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)

func set_music_volume(value : float):
	music_volume = value
	var volume_db : float = 20*log(float(value)/100.0)/log(10.0)
	# -INF (when new_value = 0) doesn't seem to pose any issues!
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume_db)

func set_mute_music(value : bool):
	mute_music = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), value)

func set_sfx_volume(value : float):
	sfx_volume = value
	var volume_db : float = 20*log(float(value)/100.0)/log(10.0)
	# -INF (when new_value = 0) doesn't seem to pose any issues!
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), volume_db)

func set_mute_sfx(value : bool):
	mute_sfx = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), value)
