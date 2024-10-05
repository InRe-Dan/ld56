## Factory class for creating new web objects
class_name WebFactory extends Node2D

const web_looseness = 0.9 ## Smaller number makes webs artificially tighter

var web_scene: PackedScene = preload("res://web/web.tscn")


## Creates a web between two points
func create_web(point_a: Vector2, point_b: Vector2) -> void:
	# TODO: Implement the logic for creating a web. I imagine webs to be constructed of individual segments.
	# This method could compute an appropriate number of segments to create a web between the two points and then make
	# that many calls to the _create_web_segment() method.
	# The method signature for this method may also need to be changed.
	pass


## Creates a new web segment
func _create_web_segment(web_position: Vector2, connection: PhysicsBody2D = null) -> void:
	# TODO: Change web segment creation logic.
	
	# Instantiate new web object
	var web: Web = web_scene.instantiate() as Web
	web.position = web_position
	if connection == null:
		web.freeze = true
		web.resting_length = 0.0
	else:
		web.connection_object = connection
		web.resting_length = web.position.distance_to(connection.position) * web_looseness

	add_child(web)
