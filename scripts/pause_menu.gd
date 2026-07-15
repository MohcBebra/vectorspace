extends PanelContainer

@onready var master_slider: HSlider = $Settings/VBoxContainer/Audio/MasterSlider
@onready var music_slider: HSlider = $Settings/VBoxContainer/Audio/MusicSlider
@onready var sfx_slider: HSlider = $Settings/VBoxContainer/Audio/SFXSlider
@onready var center: VBoxContainer = $Center
@onready var settings: ScrollContainer = $Settings


func _ready() -> void:
	_on_master_slider_value_changed(master_slider.value)
	_on_music_slider_value_changed(music_slider.value)
	_on_sfx_slider_value_changed(sfx_slider.value)

func _on_return_button_down() -> void:
	hide()

func _on_settings_button_down() -> void:
	center.hide()
	settings.show()

func _on_exit_button_down() -> void:
	pass # Replace with function body.


func _on_master_slider_value_changed(value: float) -> void:
	if value == 0.0:
		AudioServer.set_bus_mute(0, true)
		return
	AudioServer.set_bus_mute(0, false)
	var new_db: float = -80. * (100. - value) / 150.
	AudioServer.set_bus_volume_db(0, new_db)

func _on_music_slider_value_changed(value: float) -> void:
	if value == 0.0:
		AudioServer.set_bus_mute(1, true)
		return
	AudioServer.set_bus_mute(1, false)
	var new_db: float = -80. * (100. - value) / 150.
	AudioServer.set_bus_volume_db(1, new_db)

func _on_sfx_slider_value_changed(value: float) -> void:
	if value == 0.0:
		AudioServer.set_bus_mute(2, true)
		return
	AudioServer.set_bus_mute(2, false)
	var new_db: float = -80. * (100. - value) / 150.
	AudioServer.set_bus_volume_db(2, new_db)


func _on_settings_back_button_down() -> void:
	center.show()
	settings.hide()
