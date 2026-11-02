extends Node

const PATH := "user://settings.cfg"

var volume: float = 1.0
var fullscreen: bool = false


func _ready() -> void:
	load_settings()
	apply()


func apply() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.0001)))
	AudioServer.set_bus_mute(0, volume <= 0.0)
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", volume)
	config.set_value("video", "fullscreen", fullscreen)
	config.save(PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return
	volume = config.get_value("audio", "volume", 1.0)
	fullscreen = config.get_value("video", "fullscreen", false)
