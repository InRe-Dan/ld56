class_name Web extends RigidBody2D

var connection_object: PhysicsBody2D
var spring: DampedSpringJoint2D

# Spring parameters
var resting_length: float = 0.0
var stiffness: float = 20.0
var damping: float = 64.0

@onready var visual: Line2D = $VisualMask
@onready var collision: CollisionPolygon2D = $CollisionMask


## Called every physics frame
func _physics_process(delta: float) -> void:
	if connection_object == null or not is_instance_valid(connection_object): return
	
	# Apply spring physics
	var direction: Vector2 = (position - connection_object.position).normalized()
	var distance: float = position.distance_to(connection_object.position)
	var magnitude: float = (distance - resting_length) * stiffness
	var damping_force: float = 0.0
	if connection_object is RigidBody2D:
		damping_force = (connection_object.linear_velocity - linear_velocity).dot(direction) * damping
	var spring_force: Vector2 = -direction * (magnitude - damping_force)
	apply_force(spring_force, position)
	if (connection_object is RigidBody2D):
		(connection_object as RigidBody2D).apply_force(-spring_force, connection_object.position)


## Called every frame
func _process(delta: float) -> void:
	if connection_object == null or not is_instance_valid(connection_object): return
	
	# Draw web
	var endpoints: PackedVector2Array = [0, to_local(connection_object.global_position)]
	visual.points = endpoints
	collision.polygon = endpoints
