## Web segment class
class_name Web extends RigidBody2D

const debug_colors: Array = [Color.AQUA, Color.AQUAMARINE, Color.CORAL, Color.CADET_BLUE, Color.DARK_SALMON,
Color.FIREBRICK, Color.LIGHT_CORAL, Color.GOLD, Color.YELLOW_GREEN, Color.VIOLET]

var point_a : WebJoint:
	set(x):
		x.add_web(self)
		point_a = x

var point_b : WebJoint:
	set(x):
		x.add_web(self)
		point_b = x

var spring: DampedSpringJoint2D

# Spring parameters
var resting_length: float = 0
var stiffness: float = 640.0
var damping: float = 1.0

@onready var visual: Line2D = $VisualMask
@onready var collision: CollisionPolygon2D = $CollisionMask
@onready var web_factory : WebFactory = get_tree().get_first_node_in_group("web_factory")


## Called when this node enters the scene tree for the first time
func _ready() -> void:
	assert(point_a)
	assert(point_b)
	visual.modulate = debug_colors.pick_random()


## Called every physics frame
func _physics_process(delta: float) -> void:
	if not (is_instance_valid(point_a) and is_instance_valid(point_b)): return
	
	# Apply spring physics
	var direction: Vector2 = point_a.global_position.direction_to(point_b.global_position)
	var magnitude: float = (point_a.position.distance_to(point_b.position) - resting_length) * stiffness

	var spring_force: Vector2 = direction * magnitude
	if point_a.body is RigidBody2D:
		point_a.body.apply_force(+ spring_force)
	if point_b.body is RigidBody2D:
		point_b.body.apply_force(- spring_force)
		
	if point_a.global_position.distance_squared_to(point_b.global_position) < Global.web_length * 2:
		pass
		#web_factory.weld(self)
	
	# Draw web
	var endpoints: PackedVector2Array = [point_a.global_position, point_b.global_position]
	visual.points = endpoints
	collision.polygon = endpoints


## Queues for deletion and removes itself from weblists
func destroy() -> void:
	point_a.update_web_list.call_deferred()
	point_b.update_web_list.call_deferred()
	queue_free()
