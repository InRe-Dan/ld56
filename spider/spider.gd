class_name Spider extends RigidBody2D

var movement_speed: float = 512.0 # Actual velocity divides damping factor
var rotation_speed: float = 4.0

var cast_length: float = 50.0

@onready var up_cast: RayCast2D = $Upcast
@onready var down_cast: RayCast2D = $Downcast
@onready var left_cast: RayCast2D = $Leftcast
@onready var right_cast: RayCast2D = $Rightcast


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
	
	linear_velocity += input_vector * movement_speed * delta * (speed_mod / cast_length)
	
	# Rotate spider to face input vector
	if input_vector != Vector2.ZERO:
		global_rotation = rotate_toward(global_rotation, input_vector.angle(), delta * rotation_speed)


## Updates the cast length of the spider
func update_cast_length(new_length: float) -> void:
	up_cast.target_position = Vector2(0, -cast_length)
	down_cast.target_position = Vector2(0, cast_length)
	left_cast.target_position = Vector2(-cast_length, 0)
	right_cast.target_position = Vector2(cast_length, 0)


## Returns the intersection strength of the passed ray
func _get_intersection_strength(ray: RayCast2D) -> float:
	if ray.is_colliding():
		var intersection: Vector2 = ray.get_collision_point()
		return position.distance_to(intersection)
	else:
		return cast_length
