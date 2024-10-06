class_name Fly extends Node2D

@export var spin_speed : float = 0.4
@export var acceleration : float = 40
@export var max_speed : float = 100
@export var energy_gain : float = 10

var spawning : bool = true
var velocity : Vector2 
var target_dir : Vector2 = Vector2.from_angle(TAU * randf())
var change_dir_time : float = 1 + randf()
var initial_damage : float = 0.5
var struggle_damage : float = 0.1
var stuck_to : Web

signal SPLAT(position)

@onready var eyes : RayCast2D = $Eyes
@onready var avoidance_cooldown : float = 0

func enable() -> void:
	$SpawnFlourish.emitting = true
	$Hurtbox/CollisionShape2D.disabled = false
	spawning = false
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Hurtbox/CollisionShape2D.disabled = true
	modulate.a = 0
	var mod_tween : Tween = create_tween()
	mod_tween.tween_property(self, "modulate:a", 0.5, 0.5)
	mod_tween.tween_property(self, "modulate:a", 1.0, 1.0)
	mod_tween.tween_callback(enable)

	var scale_tween : Tween = create_tween()
	scale = scale * 0.1
	scale_tween.tween_property(self, "scale", scale * 10, 1.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spawning:
		return
	if change_dir_time < 0:
		change_dir_time = 1 + randf()
		target_dir = Vector2.from_angle(TAU * randf())
	
	# Deal damage to web if stuck
	if is_instance_valid(stuck_to):
		if randf() < delta:
			print(self, " ", stuck_to)
			stuck_to.damage(struggle_damage)
		
		if not is_instance_valid(stuck_to) or not (is_instance_valid(stuck_to.point_a) and is_instance_valid(stuck_to.point_b)): return
		global_position = (stuck_to.point_a.global_position + stuck_to.point_b.global_position) / 2.0
	else:
		stuck_to = null

	change_dir_time -= delta
	avoidance_cooldown -= delta
	
	if avoidance_cooldown < 0: 
		eyes.target_position = velocity.normalized() * 100
		eyes.force_raycast_update()
		if eyes.is_colliding():
			avoidance_cooldown = 0.5 + randf()
			target_dir = - velocity.normalized()
	else:
		eyes.target_position = Vector2()
	velocity += target_dir * delta * acceleration
	velocity = velocity.limit_length(max_speed)
	global_position += velocity * delta


func kill(blood_splatter_dir : Vector2) -> void:
	$Blood.direction = blood_splatter_dir
	$Blood.emitting = true
	$Blood.finished.connect($Blood.queue_free)
	$Blood.reparent(get_parent())
	var fly_position = position
	SPLAT.emit(fly_position)
	queue_free()


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if is_instance_valid(stuck_to) or stuck_to != null: return
	var web : Web = body as Web
	assert(web)
	# Placeholder logic
	stuck_to = web
	web.destroyed.connect(_on_capturing_web_destroyed)
	web.damage(initial_damage)
	velocity = Vector2(0, 0)


## Web that this insect is stuck to was destroyed
func _on_capturing_web_destroyed() -> void:
	if is_instance_valid(stuck_to): stuck_to.destroyed.disconnect(_on_capturing_web_destroyed)
	stuck_to = null
