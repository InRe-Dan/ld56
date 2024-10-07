extends Control

@onready var volume_label : Label = $VBoxContainer/VolumeSlider/Amount
@onready var volume_slider : HSlider = $VBoxContainer/VolumeSlider/Volume
@onready var phobia_button : Button = $VBoxContainer/ArachnophobiaMode/PhobiaButton


## Node entered the scene tree for the first time
func _ready() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(Global.global_volume/volume_slider.max_value))
	volume_label.text = str(round(Global.global_volume)) + "%"
	if Global.phobia_mode:
		phobia_button.text = "ON"
	else:
		phobia_button.text = "OFF"


## Play button pressed
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://world/world.tscn")


## Volume slider adjusted
func _on_volume_value_changed(value: float) -> void:
	Global.global_volume = value
	volume_label.text = str(round(value)) + "%"
	AudioServer.set_bus_volume_db(0, linear_to_db(value/volume_slider.max_value))


## Arachnophobia button pressed
func _on_phobia_button_pressed() -> void:
	Global.phobia_mode = not Global.phobia_mode
	if Global.phobia_mode:
		phobia_button.text = "ON"
	else:
		phobia_button.text = "OFF"
