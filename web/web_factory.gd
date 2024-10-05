## Factory class for creating new web objects
class_name WebFactory extends Node2D

const web_length : float = 50
const web_looseness : float = 0.9 ## Smaller number makes webs artificially tighter

var web_scene: PackedScene = preload("res://web/web.tscn")

## Creates a web between two points
func create_web(point_a: Vector2, point_b: Vector2) -> void:
	var distance : float = point_a.distance_to(point_b)
	var distance_created : float = 0
	var direction : Vector2 = point_a.direction_to(point_b)
	while distance > 0:
		var new_web_length : float = min(distance, web_length)
		var start = point_a + direction * distance_created
		distance_created += new_web_length
		var end = point_a + direction * distance_created
		var rigid : RigidBody2D = RigidBody2D.new()
		rigid.global_position = end
		_create_web_segment(start, rigid)
		distance -= web_length


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
