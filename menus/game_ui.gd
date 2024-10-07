extends Control

@onready var spider : Spider = get_tree().get_first_node_in_group("spider")
@onready var reticle : Sprite2D = $WebReticle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$TextureProgressBar.value = spider.energy
	
	var aim : Vector2 = spider.get_websling_position()
	if aim == Vector2(-1, -1):
		reticle.visible = false
	else:
		if not reticle.visible:
			reticle.visible = true
			reticle.global_position = aim
		else:
			reticle.global_position = lerp(reticle.global_position, aim, clamp(5 * delta, 0, 1.0))
