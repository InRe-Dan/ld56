class_name Spider extends RigidBody2D

var bullet_scene : PackedScene = preload("res://spider/web_bullet.tscn")

@export var energy_cap = 100
@export var enery_drain_per_second = 0.5
@export var web_cost = 2.5
@export var jump_cost = 3
@onready var energy = energy_cap:
	set(x):
		energy = clamp(x, 0, energy_cap)
		if energy == 0:
			# TODO
			print("GAME OVER!!!")

const damping: float = 4.0

var movement_speed: float = 512.0 # Actual velocity divides damping factor
var rotation_speed: float = 2.5
var sway_influence : float = 1.0 # Influence of nearby velocities

var cast_length: float = 64.0:
	set(x): update_cast_length(x)
var safety_cast_length : float = 100

@onready var destruction_zone: Area2D = $DestructionZone
@onready var up_cast: RayCast2D = $MainRays/Upcast
@onready var down_cast: RayCast2D = $MainRays/Downcast
@onready var left_cast: RayCast2D = $MainRays/Leftcast
@onready var right_cast: RayCast2D = $MainRays/Rightcast
@onready var safety_cast : ShapeCast2D = $Safety
@onready var web_cast : RayCast2D = $WebCast
@onready var factory : WebFactory = get_tree().get_first_node_in_group("web_factory")

@onready var legs : Array[Node] = $Legs/LegTargets.get_children()


## Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Configure lengths of rays
	update_cast_length(cast_length)
	linear_damp = damping

## Returns ratio of legs planted on a web or on a branch
func get_groundedness() -> float:
	var sum : float = 0
	for leg : Leg in legs:
		if leg.on_branch: sum += 1
	return sum / legs.size()

## Called every physics frame
func _physics_process(delta: float) -> void:
	energy -= delta
	# Get input vector
	var input_vector = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	# Speed formula
	var speed_mod: float = max(
		2 * cast_length - max(_get_intersection_strength(up_cast) + _get_intersection_strength(down_cast), cast_length),
		2 * cast_length - max(_get_intersection_strength(left_cast) + _get_intersection_strength(right_cast), cast_length)
	)
	
	# Rotate spider to face input vector
	if input_vector != Vector2.ZERO:
		global_rotation = rotate_toward(global_rotation, input_vector.angle() + PI / 2, delta * rotation_speed)
		safety_cast.global_rotation = 0
		safety_cast.target_position = input_vector * safety_cast_length
		if safety_cast.is_colliding():
			speed_mod = max(speed_mod, cast_length * 0.5)
	
	if is_zero_approx(speed_mod):
		gravity_scale = 1.0
		linear_damp = 0.0
	else:
		gravity_scale = 0.0
		linear_damp = damping
	
	# Apply velocity
	linear_velocity += (input_vector * get_groundedness() * 4 * movement_speed * delta * (speed_mod / cast_length) +
		(_get_intersect_velocity(up_cast) + _get_intersect_velocity(down_cast)
		+ _get_intersect_velocity(left_cast) + _get_intersect_velocity(right_cast)) * delta * sway_influence)


## Handles input events from the input stack not previously handled this frame
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire_web"): shoot_web_bullet() # shoot_web()
	elif event.is_action_pressed("destroy_web"): destroy_webs()
	elif event.is_action_pressed("jump"): jump()


func jump() -> void:
	if get_groundedness() == 0:
		return
	if energy < jump_cost:
		return
	var input_vector = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	if input_vector == Vector2.ZERO:
		return
	energy -= jump_cost
	linear_velocity = 500 * input_vector
	

## Updates the cast length of the spider
func update_cast_length(new_length: float) -> void:
	up_cast.target_position = Vector2(0, -cast_length)
	down_cast.target_position = Vector2(0, cast_length)
	left_cast.target_position = Vector2(-cast_length, 0)
	right_cast.target_position = Vector2(cast_length, 0)


## Returns a list of bodies within the destruction area
func _get_destruction_overlaps() -> Array[Web]:
	var webs : Array[Web]
	var bodies: Array[Node2D] = destruction_zone.get_overlapping_bodies()
	for body : Node2D in bodies:
		if body is Web: webs.append(body as Web)

	return webs


## Returns the intersection strength of the passed ray
func _get_intersection_strength(ray : RayCast2D) -> float:
	if ray.is_colliding():
		var intersection: Vector2 = ray.get_collision_point()
		return position.distance_to(intersection)
	else:
		return cast_length


## Returns the linear velocity of the collider of the passed ray
func _get_intersect_velocity(ray : RayCast2D) -> Vector2:
	if ray.is_colliding():
		var collider: PhysicsBody2D = ray.get_collider()
		if collider is Web:
			return collider.velocity
		else:
			return Vector2.ZERO
	else:
		return Vector2.ZERO

func get_websling_position() -> Vector2:
	var dir : Vector2 = global_position.direction_to(get_global_mouse_position())
	web_cast.global_rotation = 0
	web_cast.global_position = global_position + dir * cast_length * 1.5
	web_cast.target_position = dir * 5000
	web_cast.force_raycast_update()
	if web_cast.is_colliding():
		return web_cast.get_collision_point()
	else: return Vector2(-1, -1)


## Creates a web between two Vectors
func make_web(from : Vector2, to : Vector2) -> void:
	var pos : Vector2 = get_websling_position()
	if pos != Vector2(-1, -1):
		factory.create_web(from, to)


## Fires a web creating projectile
func shoot_web_bullet() -> void:
	var from = global_position
	if energy < web_cost + 10:
		print("Can't make a web! Too low on energy!")
		return
	energy -= web_cost
	var pos : Vector2 = get_global_mouse_position()
	var bullet : WebBullet = bullet_scene.instantiate()
	bullet.global_rotation = web_cast.global_position.direction_to(get_global_mouse_position()).angle()
	bullet.global_position = web_cast.global_position
	bullet.hit.connect(func(to : Vector2): make_web(from, to))
	add_sibling(bullet)


## Deprecated
func shoot_web() -> void:
	if energy < web_cost + 10:
		print("Can't make a web! Too low on energy!")
		return
	var pos : Vector2 = get_websling_position()
	if pos != Vector2(-1, -1):
		energy -= web_cost
		factory.create_web(global_position, web_cast.get_collision_point())


## Destroys the web in front of you
func destroy_webs() -> void:
	for web : Web in _get_destruction_overlaps():
		web.destroy()


func _on_mouth_area_entered(area: Area2D) -> void:
	var opp : Insect = area.get_parent()
	energy += opp.mob_data.energy_gain
	opp.kill($Mouth.global_position.direction_to(area.global_position))
