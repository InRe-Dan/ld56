extends Node2D


const web_length : float = 50.0

func _ready() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(0.2))
