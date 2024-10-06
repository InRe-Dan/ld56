class_name Spider extends RigidBody2D

var movement_speed: float = 512.0 # Actual velocity divides damping factor
var rotation_speed: float = 4.0
var sway_influece : float = 2.0 # Influence of nearby velocities

var cast_length: float = 64.0:
	set(x): update_cast_length(x)
var safety_cast_length : float = 100

@onready var up_cast: RayCast2D = $MainRays/Upcast
@onready var down_cast: RayCast2D = $MainRays/Downcast
@onready var left_cast: RayCast2D = $MainRays/Leftcast
@onready var right_cast: RayCast2D = $MainRays/Rightcast
@onready var safety_cast : ShapeCast2D = $Safety
@onready var web_cast : RayCast2D = $WebCast
@onready var factory : WebFactory = get_tree().get_first_node_in_group("web_factory")


## Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Configure lengths of rays
	update_cast_length(cast_length)


## Called every physics frame
func _physics_process(delta: float) -> void:
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
	
	# Apply velocity
	linear_velocity += (input_vector * movement_speed * delta * (speed_mod / cast_length) +
		(_get_intersect_velocity(up_cast) + _get_intersect_velocity(down_cast)
		+ _get_intersect_velocity(left_cast) + _get_intersect_velocity(right_cast)) * delta * sway_influece)


## Updates the cast length of the spider
func update_cast_length(new_length: float) -> void:
	up_cast.target_position = Vector2(0, -cast_length)
	down_cast.target_position = Vector2(0, cast_length)
	left_cast.target_position = Vector2(-cast_length, 0)
	right_cast.target_position = Vector2(cast_length, 0)


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


## Fires a web at the current mouse position
func shoot_web() -> void:
	web_cast.global_rotation = 0
	var dir : Vector2 = global_position.direction_to(get_global_mouse_position())
	web_cast.global_position = global_position + dir * 50
	web_cast.target_position = dir * 5000
	web_cast.force_raycast_update()
	if web_cast.is_colliding():
		factory.create_web(global_position, web_cast.get_collision_point())
	

## Handles input events from the input stack not previously handled this frame
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Left mouse pressed
		if event.button_index == 1 and event.pressed:
			shoot_web()


func _on_mouth_area_entered(area: Area2D) -> void:
	(area.get_parent() as Fly).kill($Mouth.global_position.direction_to(area.global_position))

func _on_web_indicator_timer_timeout() -> void:
		$"../WebIndicator".visible = false
