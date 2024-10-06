@icon("res://assets/editor_icons/control/icon_event.png")
extends Control

@onready var spider : Spider = get_tree().get_first_node_in_group("spider")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$TextureProgressBar.value = spider.energy
