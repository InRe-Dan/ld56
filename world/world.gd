@icon("res://assets/editor_icons/node_2D/icon_flag.png")
extends Node2D

@onready var spider : Spider = $Spider


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.phobia_mode:
		spider.get_node("Legs").visible = false
		spider.get_node("Body").visible = false


func game_over() -> void:
	pass


func _on_killbox_body_entered(body: Node2D) -> void:
	# classic
	(body as Spider).energy -= 99999999
