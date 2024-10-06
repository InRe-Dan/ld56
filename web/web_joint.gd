## Web segment connection point
class_name WebJoint extends PhysicsBody2D

const default_mass : float = 1.0

@export var body : PhysicsBody2D
var webs : Array[Web]

var velocity : Vector2:
	get:
		if body is RigidBody2D:
			return body.linear_velocity
		return Vector2.ZERO


## Called when the node enters the scene tree for the first time
func _ready() -> void:
	assert(body)
	body.top_level = true
	body.global_position = global_position
	if body is RigidBody2D:
		(body as RigidBody2D).mass = default_mass


## Called every physics frame
func _physics_process(_delta: float) -> void:
	global_position = body.global_position
	if body is RigidBody2D:
		if webs.size() == 1:
			(body as RigidBody2D).mass = 10 * default_mass
		else:
			(body as RigidBody2D).mass = default_mass


## Adds a new web to this joint
func add_web(web : Web) -> void:
	webs.append(web)
	
	
## Removes the passed web from this joint
func remove_web(web : Web) -> void:
	var index : int = webs.find(web)
	if index >= 0: webs.remove_at(index)
