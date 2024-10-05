## Factory class for creating new web objects
class_name WebFactory extends Node2D

const web_length : float = 50
const web_looseness : float = 0.9 ## Smaller number makes webs artificially tighter

var web_scene: PackedScene = preload("res://web/web.tscn")
var anchor_joint_scene : PackedScene = preload("res://web/anchor_web_joint.tscn")
var moveable_joint_scene : PackedScene = preload("res://web/moveable_web_joint.tscn")

@onready var web_scout : ShapeCast2D = $WebScout
@onready var joint_scout : ShapeCast2D = $JointScout


## Turns a web's two joints into one, destroying the web in the process.
func weld(web : Web) -> void:
	var survivor : WebJoint = null
	var killed : WebJoint = null
	if (web.point_a.body is StaticBody2D):
		survivor = web.point_a
		killed = web.point_b
	elif (web.point_b.body is StaticBody2D):
		survivor = web.point_b
		killed = web.point_a
	else:
		# Choose arbitrarily
		survivor = web.point_a
		killed = web.point_b
	
	for connected_web : Web in killed.webs:
		if web.point_a == killed:
			web.point_a = survivor
		if web.point_b == killed:
			web.point_b = survivor
	print("Freed ", killed)
	print("Didn't free ", survivor)
	web.destroy()
	killed.queue_free()

## Splits a web into two, destroying the original. Returns the two segments' connecting joint.
func split(web : Web, pos : Vector2) -> WebJoint:
	var new_joint : WebJoint = moveable_joint_scene.instantiate()
	new_joint.global_position = pos
	add_child(new_joint)
	_create_web_segment(web.point_a, new_joint)
	_create_web_segment(new_joint, web.point_b)
	web.destroy()
	return new_joint
	

## Return true if there is a webbable point here (branch, joint or web)
func check_for_object(pos : Vector2) -> bool:
	joint_scout.global_position = pos
	web_scout.global_position = pos
	joint_scout.force_shapecast_update()
	web_scout.force_shapecast_update()
	return web_scout.is_colliding() or joint_scout.is_colliding()


## This will either check for an existing joint near this point 
## or create and add a new one to the scene tree.
func get_joint_at(pos : Vector2) -> WebJoint:
	joint_scout.global_position = pos
	web_scout.global_position = pos
	joint_scout.force_shapecast_update()
	web_scout.force_shapecast_update()
	var joint : WebJoint = null

	# First check if any pivots already exist here
	if joint_scout.is_colliding():
		print("A")
		joint = joint_scout.get_collider(0).get_parent()
	# Otherwise check if branches or webs exist
	elif web_scout.is_colliding():
		print("B")
		var object : PhysicsBody2D = web_scout.get_collider(0)
		if object is StaticBody2D:
			# This must be a tree
			joint = anchor_joint_scene.instantiate()
			joint.global_position = web_scout.get_collision_point(0)
			add_child(joint)
		elif object is RigidBody2D:
			# This must be a web. We need to split it into two and make a pivot here.
			var web : Web = object as Web
			joint = split(web, pos)
		else: assert(false) # huh
	
	if not joint:
		joint = moveable_joint_scene.instantiate()
		joint.global_position = pos
		add_child(joint)

	return joint

## Creates a web between two points
func create_web(point_a: Vector2, point_b: Vector2) -> void:
	if not (check_for_object(point_a) and check_for_object(point_b)):
		print("Can't create web here.")
		return

	var distance: float = point_a.distance_to(point_b)
	var distance_created: float = 0
	var direction: Vector2 = point_a.direction_to(point_b)
	
	var start_joint: WebJoint = get_joint_at(point_a)

	while distance > 0:
		var new_web_length: float = min(distance, web_length)
		var start = point_a + direction * distance_created
		distance_created += new_web_length
		var end = point_a + direction * distance_created
		var new_joint: WebJoint = get_joint_at(end)
		if not new_joint:
			return
		assert(start_joint.global_position != Vector2())
		_create_web_segment(start_joint, new_joint)
		start_joint = new_joint
		distance -= web_length


## Creates a new web segment
func _create_web_segment(point_a : WebJoint, point_b : WebJoint = null) -> void:
	# Instantiate new web object
	var web: Web = web_scene.instantiate() as Web
	web.point_a = point_a
	web.point_b = point_b
	web.resting_length = point_a.position.distance_to(point_b.position) * web_looseness

	add_child(web)
