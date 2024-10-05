class_name WebJoint extends Node2D

## Can be either static or rigid (for anchors and moveable points respectively)
@export var body : PhysicsBody2D
var webs : Array[Web]

var linear_velocity : Vector2:
	get:
		if body is RigidBody2D:
			return body.linear_velocity
		return Vector2()
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(body)
	body.top_level = true
	body.global_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position = body.global_position

func update_web_list() -> void:
	webs.filter(func (x): is_instance_valid(x))
	if not webs:
		queue_free()
		
func add_web(web : Web) -> void:
	webs.append(web)
