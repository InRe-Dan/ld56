class_name WebBullet extends Node2D

const speed : float = 2.0

@onready var detection : ShapeCast2D = $Detection
@onready var particles : CPUParticles2D = $CPUParticles2D

signal hit(pos : Vector2)

func _physics_process(delta: float) -> void:
	if detection.is_colliding():
		hit.emit(detection.get_collision_point(0))
		queue_free()
		particles.reparent(get_parent())
		particles.emitting = false
		get_tree().create_timer(particles.lifetime).timeout.connect(particles.queue_free)
	global_position += global_transform.x * 1000 * delta * speed
