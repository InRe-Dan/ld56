extends Node2D

const web_length : float = 50.0

var global_volume : float = 15.0
var phobia_mode : bool = false

var time_played : float = 0.0
var insects_devoured : int = 0
var webs_created : int = 0

@onready var snap : AudioStreamPlayer = $Snap


func toggle_band_pass(state : bool) -> void:
	if not state:
		var bandpass_filter := AudioEffectBandPassFilter.new()
		bandpass_filter.cutoff_hz = 1000
		bandpass_filter.resonance = 0.65
		AudioServer.add_bus_effect(0, bandpass_filter, 0)
	else:
		AudioServer.remove_bus_effect(0, 0)


func play_click_sound() -> void:
	$ButtonClick.play()


func play_snap_sound() -> void:
	var new : AudioStreamPlayer = snap.duplicate()
	add_child(new)
	new.playing = true
	new.finished.connect(new.queue_free)
