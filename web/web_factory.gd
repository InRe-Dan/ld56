## Factory class for creating new web objects
class_name WebFactory extends Node2D

var web_scene : PackedScene = preload("res://web/web.tscn")
var static_joint_scene : PackedScene = preload("res://web/static_joint.tscn")
var rigid_joint_scene : PackedScene = preload("res://web/rigid_joint.tscn")

@onready var final_scout : ShapeCast2D = $FinalScout
@onready var initial_scout : ShapeCast2D = $InitialScout

## Turns a web's two joints into one, destroying the web in the process.
func weld(web : Web) -> void:
	var root : WebJoint = web.point_a
	var floating : WebJoint = web.point_b

	# Favor point_b if it is static
	if (web.point_b.body is StaticBody2D):
		root = web.point_b
		floating = web.point_a
	
	# Join decoupled webs to other end
	for connection : Web in floating.webs:
		if not is_instance_valid(connection): continue
		if connection.point_a == floating:
			connection.point_a = root
		else:
			connection.point_b = root

	web.destroy()
	floating.queue_free()


## Splits a web into two, destroying the original. Returns the two segments' connecting joint.
func split(web : Web, pos : Vector2) -> WebJoint:
	var new_joint : WebJoint = rigid_joint_scene.instantiate()
	new_joint.global_position = pos
	add_child(new_joint)
	if not (is_instance_valid(web.point_a) and is_instance_valid(web.point_b)): return new_joint
	_create_web_segment(web.point_a.global_position.distance_to(new_joint.global_position), web.point_a, new_joint)
	_create_web_segment(web.point_b.global_position.distance_to(new_joint.global_position), new_joint, web.point_b)
	web.destroy()
	return new_joint
	

## Return true if there is a webbable point here (branch, joint or web)
func check_for_object(scout : ShapeCast2D, pos : Vector2) -> bool:
	scout.global_position = pos
	scout.force_shapecast_update()
	return scout.is_colliding()


## This will either check for an existing joint near this point 
## or create and add a new one to the scene tree.
func get_joint_at(scout : ShapeCast2D, pos : Vector2) -> WebJoint:
	scout.global_position = pos
	scout.force_shapecast_update()
	var joint : WebJoint = null

	# Otherwise check if branches or webs exist
	if scout.is_colliding():
		var scout_pos : Vector2 = scout.get_collision_point(0)
		var object : Node2D = scout.get_collider(0)

		if object is WebJoint:
			# Joint already here
			joint = object as WebJoint
		elif object is Web:
			# This must be a web. We need to split it into two and make a pivot here.
			var web : Web = object as Web
			joint = split(web, pos)
		else:
			# This must be a tree
			joint = static_joint_scene.instantiate()
			joint.global_position = scout_pos
			add_child(joint)

	if not joint:
		# Create arbitrary joint
		joint = rigid_joint_scene.instantiate()
		joint.global_position = pos
		add_child(joint)

	return joint


## Creates a web between two points
func create_web(point_a: Vector2, point_b: Vector2) -> void:
	if not (check_for_object(initial_scout, point_a) and check_for_object(final_scout, point_b)):
		return

	var distance: float = point_a.distance_to(point_b)
	if distance < Global.web_length:
		return

	var distance_created: float = 0
	var direction: Vector2 = point_a.direction_to(point_b)
	
	var start_joint: WebJoint = get_joint_at(initial_scout, point_a)

	while distance > 0:
		# Calculate distance of next segment
		var new_web_length: float
		if distance > Global.web_length * 1.5:
			new_web_length = Global.web_length
		else:
			new_web_length = distance
		
		# Place points
		var start = point_a + direction * distance_created
		distance_created += new_web_length
		var end = point_a + direction * distance_created
		
		var new_joint: WebJoint = get_joint_at(final_scout, end)
		if not new_joint:
			return

		_create_web_segment(new_web_length, start_joint, new_joint)
		start_joint = new_joint
		distance -= new_web_length
	
	Global.webs_created += 1


## Creates a new web segment
func _create_web_segment(length : float, point_a : WebJoint, point_b : WebJoint = null) -> void:
	# Instantiate new web object
	var web: Web = web_scene.instantiate() as Web
	web.point_a = point_a
	web.point_b = point_b

	add_child(web)
