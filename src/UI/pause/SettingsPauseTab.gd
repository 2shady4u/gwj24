extends class_pause_tab

onready var _back_button := $VBoxContainer/BackButton

onready var _content_vbox :=  $VBoxContainer/ScrollContainer/VBoxContainer

onready var _master_volume_label := _content_vbox.get_node("AudioContainer/MasterVolumeHBox/VolumeLabel")
onready var _master_volume_slider := _content_vbox.get_node("AudioContainer/MasterVolumeHBox/VolumeSlider")

onready var _music_volume_label := _content_vbox.get_node("AudioContainer/MusicVolumeHBox/VolumeLabel")
onready var _music_volume_slider := _content_vbox.get_node("AudioContainer/MusicVolumeHBox/VolumeSlider")
onready var _mute_music_check_box := _content_vbox.get_node("AudioContainer/MuteMusicCheckBox")

onready var _sfx_volume_label := _content_vbox.get_node("AudioContainer/SFXVolumeHBox/VolumeLabel")
onready var _sfx_volume_slider := _content_vbox.get_node("AudioContainer/SFXVolumeHBox/VolumeSlider")
onready var _mute_sfx_check_box := _content_vbox.get_node("AudioContainer/MuteSFXCheckBox")

func _ready():
	var _error : int = _back_button.connect("pressed", self, "_on_back_button_pressed")

	_error = _master_volume_slider.connect("value_changed", self, "_on_master_volume_slider_changed")

	_error = _music_volume_slider.connect("value_changed", self, "_on_music_volume_slider_changed")
	_error = _mute_music_check_box.connect("toggled", self, "_on_mute_music_check_box_toggled")
		
	_error = _sfx_volume_slider.connect("value_changed", self, "_on_sfx_volume_slider_changed")
	_error = _mute_sfx_check_box.connect("toggled", self, "_on_mute_sfx_check_box_toggled")

func update_tab():
	_master_volume_slider.grab_focus()
	
	_master_volume_slider.value = ConfigData.master_volume

	_music_volume_slider.value = ConfigData.music_volume
	_mute_music_check_box.pressed = ConfigData.mute_music

	_sfx_volume_slider.value = ConfigData.sfx_volume
	_mute_sfx_check_box.pressed = ConfigData.mute_sfx

func _on_mute_music_check_box_toggled(button_pressed : bool):
	ConfigData.mute_music = button_pressed

func _on_mute_sfx_check_box_toggled(button_pressed : bool):
	ConfigData.mute_sfx = button_pressed

func _on_master_volume_slider_changed(value : float):
	_master_volume_label.text = "(%3d %%)" % value
	ConfigData.master_volume = value

func _on_music_volume_slider_changed(value : float):
	_music_volume_label.text = "(%3d %%)" % value
	ConfigData.music_volume = value

func _on_sfx_volume_slider_changed(value : float):
	_sfx_volume_label.text = "(%3d %%)" % value
	ConfigData.sfx_volume = value
