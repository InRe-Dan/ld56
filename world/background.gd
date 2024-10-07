extends Node2D

@export var rain_curve : Curve

@onready var spider: Spider = %Spider
@onready var background_image: Sprite2D = %BackgroundImage
@onready var tree_branches: Sprite2D = %TreeBranches

var origin := Vector2(965, 545)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	background_image.position = origin - spider.position*0.04
	#rain_shader.set("shader_parameter/rain_amount", rain_curve.sample(min(1.0, Global.time_played/300)))
