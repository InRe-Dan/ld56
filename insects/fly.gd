class_name Fly extends Node2D

var spawning : bool = true
var velocity : Vector2i 

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
	
