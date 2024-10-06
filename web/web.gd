## Web segment class
class_name Web extends StaticBody2D

signal destroyed

const debug_colors: Array = [Color.AQUA, Color.AQUAMARINE, Color.CORAL, Color.CADET_BLUE, Color.DARK_SALMON,
Color.FIREBRICK, Color.LIGHT_CORAL, Color.GOLD, Color.YELLOW_GREEN, Color.VIOLET]

var point_a : WebJoint:
	set(x):
		if x is WebJoint:
			x.add_web(self)
		point_a = x

var point_b : WebJoint:
	set(x):
		if x is WebJoint:
			x.add_web(self)
		point_b = x

var velocity : Vector2:
	get():
		var vel_a : Vector2 = Vector2.ZERO
		var vel_b : Vector2 = Vector2.ZERO
		if is_instance_valid(point_a): vel_a = point_a.velocity
		if is_instance_valid(point_b): vel_b = point_b.velocity
		return vel_a + vel_b

# Spring parameters
var stiffness: float = 4096.0
var damping: float = 1024.0

var health : float = 1.0

@onready var visual: Line2D = $VisualMask
@onready var collision: CollisionPolygon2D = $CollisionMask
@onready var web_factory : WebFactory = get_tree().get_first_node_in_group("web_factory")
@onready var death_particles : CPUParticles2D = $DeathParticles
@onready var free_timer : Timer = $FreeTimer

var blood_radius = 130;


## Called when this node enters the scene tree for the first time
func _ready() -> void:
	assert(point_a)
	assert(point_b)
	#visual.modulate = debug_colors.pick_random()
	if $"../..".has_node("Fly"):
		$"../../Fly".connect("SPLAT",GetBloody)

## Called every physics frame
func _physics_process(delta: float) -> void:
	if not (is_instance_valid(point_a) and is_instance_valid(point_b)):
		destroy()
		return
	
	## Destroy if no neighbors
	if (point_a.webs.size() == 1 and point_a.body is RigidBody2D) or (point_b.webs.size() == 1 and point_b.body is RigidBody2D):
		if randf() < delta:
			destroy()
			return

	# Apply spring physics
	var direction: Vector2 = point_a.global_position.direction_to(point_b.global_position)
	var distance : float = point_a.position.distance_to(point_b.position)
	var magnitude: float = distance * stiffness
	
	# Destroy web if overstretched
	if distance > Global.web_length * 4:
		destroy()
		return

	var spring_force: Vector2 = (direction * magnitude - damping * (point_a.velocity - point_b.velocity)) * delta
	if point_a.body is RigidBody2D:
		point_a.body.apply_force(+ spring_force / 2)
	if point_b.body is RigidBody2D:
		point_b.body.apply_force(- spring_force / 2)

	if point_a.global_position.distance_squared_to(point_b.global_position) < Global.web_length * 4:
		pass;#web_factory.weld(self)
	
	# Draw web
	var endpoints: PackedVector2Array = [point_a.global_position, point_b.global_position]
	visual.points = endpoints
	collision.polygon = endpoints


## Queues for deletion and removes itself from weblists
func destroy() -> void:
	if not free_timer.is_stopped(): return
	if is_instance_valid(point_a): point_a.remove_web(self)
	if is_instance_valid(point_b): point_b.remove_web(self)
	death_particles.position = (point_a.position + point_b.position) / 2.0
	point_a = null
	point_b = null
	visual.visible = false
	death_particles.emitting = true
	destroyed.emit()
	free_timer.start()


## Damages the web
func damage(amount : float) -> void:
	health -= amount
	if health <= 0.0: destroy()


func GetBloody(fly_position):
	$VisualMask.material.set_shader_parameter("blood_position", fly_position)
	$VisualMask.material.set_shader_parameter("blood_radius", blood_radius)
	StartBloodFade()


func StartBloodFade():
	await get_tree().create_timer(2.0).timeout
	fade_blood_effect()


func fade_blood_effect():
	while blood_radius > 0:  # Continue fading until radius is fully reduced
		blood_radius -= 1  # Gradually decrease the radius
		$VisualMask.material.set_shader_parameter("blood_radius", blood_radius)
		await get_tree().create_timer(0.1).timeout  # Delay before next decrease


## Frees the web
func _on_free_timer_timeout() -> void:
	queue_free()
