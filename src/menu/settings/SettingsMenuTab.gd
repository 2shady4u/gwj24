extends class_menu_tab

onready var _back_button := $BackContainer/BackButton

onready var _content_vbox :=  $VBoxContainer/ScrollContainer/VBoxContainer

onready var _master_volume_label := _content_vbox.get_node("AudioContainer/MasterVolumeHBox/VolumeLabel")
onready var _master_volume_slider := _content_vbox.get_node("AudioContainer/MasterVolumeHBox/VolumeSlider")

onready var _music_volume_label := _content_vbox.get_node("AudioContainer/MusicVolumeHBox/VolumeLabel")
onready var _music_volume_slider := _content_vbox.get_node("AudioContainer/MusicVolumeHBox/VolumeSlider")
onready var _mute_music_check_box := _content_vbox.get_node("AudioContainer/MuteMusicCheckBox")

onready var _sfx_volume_label := _content_vbox.get_node("AudioContainer/SFXVolumeHBox/VolumeLabel")
onready var _sfx_volume_slider := _content_vbox.get_node("AudioContainer/SFXVolumeHBox/VolumeSlider")
onready var _mute_sfx_check_box := _content_vbox.get_node("AudioContainer/MuteSFXCheckBox")

onready var _next_button := _content_vbox.get_node("LocaleContainer/LanguageHBox/NextButton")
onready var _previous_button := _content_vbox.get_node("LocaleContainer/LanguageHBox/PreviousButton")

func _ready():
	var _error : int = _back_button.connect("pressed", self, "_on_back_button_pressed")

	_error = _master_volume_slider.connect("value_changed", self, "_on_master_volume_slider_changed")
	_error = _sfx_volume_slider.connect("value_changed", self, "_on_sfx_volume_slider_changed")
	_error = _music_volume_slider.connect("value_changed", self, "_on_music_volume_slider_changed")
	
	_error = _mute_music_check_box.connect("toggled", self, "_on_mute_music_check_box_toggled")
	_error = _mute_sfx_check_box.connect("toggled", self, "_on_mute_sfx_check_box_toggled")

	_error = _next_button.connect("pressed", self, "_on_language_button_pressed", [+1])
	_error = _previous_button.connect("pressed", self, "_on_language_button_pressed", [-1])

func update_tab():
	_master_volume_slider.grab_focus()

	_master_volume_slider.value = ConfigData.master_volume

	_music_volume_slider.value = ConfigData.music_volume
	_mute_music_check_box.pressed = ConfigData.mute_music

	_sfx_volume_slider.value = ConfigData.sfx_volume
	_mute_sfx_check_box.pressed = ConfigData.mute_sfx

func _on_back_button_pressed():
	emit_signal("button_pressed", TABS.MAIN)

func _on_mute_music_check_box_toggled(button_pressed : bool):
	ConfigData.mute_music = button_pressed

func _on_mute_sfx_check_box_toggled(button_pressed : bool):
	ConfigData.mute_sfx = button_pressed

func _on_master_volume_slider_changed(value : float):
	ConfigData.master_volume = value

func _on_music_volume_slider_changed(value : float):
	ConfigData.music_volume = value

func _on_sfx_volume_slider_changed(value : float):
	ConfigData.sfx_volume = value

func _on_language_button_pressed(increment : int):
	var loaded_locales := TranslationServer.get_loaded_locales()
	var unique_locales := []
	# loaded_locales can contain duplicate locales, wihch should be avoided!
	for locale in loaded_locales:
		if not locale in unique_locales:
			unique_locales.append(locale)

	var index := unique_locales.find(ConfigData.locale)
	index += increment
	if index >= unique_locales.size():
		ConfigData.set_locale(unique_locales[0])
	else:
		ConfigData.set_locale(unique_locales[index])
