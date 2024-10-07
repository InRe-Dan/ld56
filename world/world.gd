extends Node2D

@onready var spider : Spider = $Spider


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.toggle_band_pass(true)
	
	Global.time_played = 0.0
	Global.insects_devoured = 0
	Global.webs_created = 0
	
	if Global.phobia_mode:
		spider.get_node("Legs").visible = false
		spider.get_node("Body").visible = false


func game_over() -> void:
	pass


func _on_killbox_body_entered(body: Node2D) -> void:
	# classic
	(body as Spider).energy -= 99999999
