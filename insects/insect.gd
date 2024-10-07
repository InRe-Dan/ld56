class_name Insect extends Node2D

var mob_data : MobData:
	set(x):
		mob_data = x
		_update_mob_data()

var spawning : bool = true
var velocity : Vector2 
var target_dir : Vector2 = Vector2.from_angle(TAU * randf())
var change_dir_time : float = 1 + randf()
var stuck_to : Web

var anim_time_current : float = 0.0
var anim_frame_time : float = 0.08

signal SPLAT(position)

@onready var eyes : RayCast2D = $Eyes
@onready var avoidance_cooldown : float = 0
@onready var sprite : Sprite2D = $Sprite2D


func enable() -> void:
	$SpawnFlourish.emitting = true
	$Hurtbox/CollisionShape2D.disabled = false
	spawning = false
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(mob_data)
	$Hurtbox/CollisionShape2D.disabled = true
	modulate.a = 0
	var mod_tween : Tween = create_tween()
	mod_tween.tween_property(self, "modulate:a", 0.5, 0.5)
	mod_tween.tween_property(self, "modulate:a", 1.0, 1.0)
	mod_tween.tween_callback(enable)

	var scale_tween : Tween = create_tween()
	scale = scale * 0.1
	scale_tween.tween_property(self, "scale", scale * 10, 1.5)
	_update_mob_data()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spawning:
		return
	
	anim_time_current += delta
	if anim_time_current > anim_frame_time:
		anim_time_current -= anim_frame_time
		if sprite.frame == sprite.hframes - 1:
			sprite.frame = 0
		else:
			sprite.frame += 1
	
	if change_dir_time < 0:
		change_dir_time = 1 + randf()
		target_dir = Vector2.from_angle(TAU * randf())
	
	# Deal damage to web if stuck
	if is_instance_valid(stuck_to):
		if randf() < delta:
			stuck_to.damage(mob_data.struggle_damage)
		
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
	velocity += target_dir * delta * mob_data.acceleration
	velocity = velocity.limit_length(mob_data.max_speed)
	global_position += velocity * delta
	global_rotation = rotate_toward(global_rotation, velocity.angle() + PI/2, delta * mob_data.spin_speed)


func kill(blood_splatter_dir : Vector2) -> void:
	Global.insects_devoured += 1
	$Blood.direction = blood_splatter_dir
	$Blood.emitting = true
	$Blood.finished.connect($Blood.queue_free)
	$Blood.reparent(get_parent())
	SPLAT.emit(position)
	queue_free()


## Updates fields based on mob data
func _update_mob_data() -> void:
	if not is_instance_valid(mob_data): return
	if is_instance_valid(sprite):
		sprite.texture = mob_data.texture


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if is_instance_valid(stuck_to) or stuck_to != null: return
	var web : Web = body as Web
	assert(web)
	# Placeholder logic
	stuck_to = web
	web.destroyed.connect(_on_capturing_web_destroyed)
	web.damage(mob_data.initial_damage)
	velocity = Vector2(0, 0)


## Web that this insect is stuck to was destroyed
func _on_capturing_web_destroyed() -> void:
	if is_instance_valid(stuck_to): stuck_to.destroyed.disconnect(_on_capturing_web_destroyed)
	stuck_to = null
