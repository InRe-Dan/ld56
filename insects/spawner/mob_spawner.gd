extends Node2D

@export var top_left_marker : Marker2D
@export var bottom_right_marker : Marker2D
@export var horizontal_spread : Curve

@export var start_spawn_interval : float = 3

@export var mobs : Array[MobData]:
	get:
		return mobs.duplicate()

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var spawn_timer : float = 0.0

# Should increase in some way as the player progresses
var difficulty_metric = 1

@onready var insect_scene : PackedScene = preload("res://insects/insect.tscn")

var spawn_interval : float = 1

## Removes any mobs in the array that shouldn't be spawned right now.
func filter_by_spawnable() -> Array[MobData]:
	return mobs.filter(func x(a : MobData): return a.difficulty_requirement <= difficulty_metric)

func get_random_spawn_pos() -> Vector2:
	var h : float = horizontal_spread.sample(randf())
	var v : int = round(randf())
	var tl : Vector2 = top_left_marker.global_position
	var br : Vector2 = bottom_right_marker.global_position
	return Vector2(
		tl.x + (br.x - tl.x) * h,
		tl.y + (br.y - tl.y) * v
	)

func reset_timer() -> void:
	spawn_timer = spawn_interval + randf_range(-0.5, 0.2) * spawn_interval

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(filter_by_spawnable().size() > 0)
	reset_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	difficulty_metric += delta
	# every 10 seconds the game gets sqrt(
	spawn_interval = start_spawn_interval + pow(difficulty_metric * 0.05, 1.15)
	spawn_timer -= delta
	if spawn_timer <= 0:
		reset_timer()
		spawn()
	
func spawn() -> void:
	var candidates : Array[MobData] = filter_by_spawnable()
	var weights : PackedFloat32Array
	for candidate : MobData in candidates:
		weights.append(candidate.spawn_weight)
	var index : int = rng.rand_weighted(weights)
	var mob_data : MobData = candidates[index]
	var mob : Insect = insect_scene.instantiate()
	mob.mob_data = mob_data
	mob.global_position = get_random_spawn_pos()
	add_child(mob)
	
	
