class_name Fly extends Node2D

@export var spin_speed : float = 0.4
@export var acceleration : float = 40
@export var max_speed : float = 100

var spawning : bool = true
var velocity : Vector2 
var target_dir : Vector2 = Vector2.from_angle(TAU * randf())
var change_dir_time : float = 1 + randf()

@onready var eyes : RayCast2D = $Eyes
@onready var avoidance_cooldown : float = 0

func enable() -> void:
	$SpawnFlourish.emitting = true
	spawning = false
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0.6
	var mod_tween : Tween = create_tween()
	mod_tween.tween_property(self, "modulate:a", 1.0, 1.0)
	mod_tween.tween_callback(enable)

	var scale_tween : Tween = create_tween()
	scale = scale * 0.1
	scale_tween.tween_property(self, "scale", scale * 10, 1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spawning:
		return
	if change_dir_time < 0:
		change_dir_time = 1 + randf()
		target_dir = Vector2.from_angle(TAU * randf())
	
	change_dir_time -= delta
	avoidance_cooldown -= delta
	
	if avoidance_cooldown < 0:
		eyes.target_position = velocity.normalized() * 100
		eyes.force_raycast_update()
		if eyes.is_colliding():
			print("Oh no!")
			avoidance_cooldown = 0.5 + randf()
			target_dir = - velocity.normalized()
	else:
		eyes.target_position = Vector2()
	velocity += target_dir * delta * acceleration
	velocity = velocity.limit_length(max_speed)
	global_position += velocity * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
