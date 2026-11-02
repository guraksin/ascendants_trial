extends Control

@onready var volume_slider: HSlider = %VolumeSlider
@onready var fullscreen_check: CheckButton = %FullscreenCheck


func _ready() -> void:
	volume_slider.value = UserSettings.volume
	fullscreen_check.button_pressed = UserSettings.fullscreen
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)


func _on_volume_changed(value: float) -> void:
	UserSettings.volume = value
	UserSettings.apply()
	UserSettings.save_settings()


func _on_fullscreen_toggled(on: bool) -> void:
	UserSettings.fullscreen = on
	UserSettings.apply()
	UserSettings.save_settings()
