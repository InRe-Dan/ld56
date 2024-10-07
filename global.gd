extends Node2D

const web_length : float = 50.0

@export var bass_curve : Curve
@export var tension_a : Curve
@export var tension_b : Curve

var global_volume : float = 15.0
var phobia_mode : bool = false

var time_played : float = 0.0
var insects_devoured : int = 0
var webs_created : int = 0

@onready var snap : AudioStreamPlayer = $Snap
@onready var snap_cooldown : Timer = $SnapCooldown

@onready var main_theme : AudioStreamPlayer = $Music/Main
@onready var menu_theme : AudioStreamPlayer = $Music/Menu
@onready var bass_track : AudioStreamPlayer = $Music/Bass
@onready var tension_a_track : AudioStreamPlayer = $Music/TensionA
@onready var tension_b_track : AudioStreamPlayer = $Music/TensionB


## Switch music
func toggle_track(main : bool) -> void:
	if main:
		main_theme.volume_db = linear_to_db(1.0)
		menu_theme.volume_db = linear_to_db(0.0)
	else:
		main_theme.volume_db = linear_to_db(0.0)
		menu_theme.volume_db = linear_to_db(1.0)


## Sample tracks based on energy
func sample_tracks(energy : float) -> void:
	bass_track.volume_db = linear_to_db(bass_curve.sample(energy))
	tension_a_track.volume_db = linear_to_db(tension_a.sample(energy))
	tension_b_track.volume_db = linear_to_db(tension_b.sample(energy))


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


## Play web breaking sound
func play_snap_sound() -> void:
	if not snap_cooldown.is_stopped(): return
	snap_cooldown.start()
	snap.play()
