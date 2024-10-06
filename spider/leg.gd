class_name Leg extends Node2D


## The global position of the leg this node is attached to represents "rest position"

# Branch detection area
@onready var area : Area2D = $Area2D
# Current leg position
@onready var marker : Marker2D = $Follow
# Best place to put a leg when a branch is nearby
@onready var pref_marker : Marker2D = $Preferred

# How far a leg has to be before it is moved
const distance_threshold : float = 50
var marker_target_position : Vector2
var stepping : bool = false
var on_branch : bool = false

func NearestPointOnLine(start : Vector2, end : Vector2, pnt : Vector2) -> Vector2:
	var lineDir = start.direction_to(end)
	var v = pnt - start;
	var d = v.dot(lineDir)
	if d > start.distance_to(end):
		return Vector2(-1, -1)
	return start + lineDir * d;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(area)
	assert(marker)
	assert(pref_marker)
	marker_target_position = marker.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var rest_position : Vector2 = global_position
	var pref_position : Vector2 = pref_marker.global_position
	var marker_target_position = rest_position
	var best_dist = 100000
	on_branch = false
	if area.has_overlapping_bodies():
		for object : PhysicsBody2D in area.get_overlapping_bodies():
			for object_child : Node in object.get_children():
				if object_child is CollisionPolygon2D:
					var points : PackedVector2Array = object_child.polygon
					var closest : Vector2 = NearestPointOnLine(points[0], points[1], pref_position)
					if closest != Vector2(-1, -1):
						best_dist = closest.distance_to(pref_position)
						marker_target_position = closest
						on_branch = true

	var dist = marker_target_position.distance_to(marker.global_position)
	if dist > distance_threshold:
		stepping = true
	if dist < 5:
		stepping = false
	
	if stepping:
		marker.global_position = lerp(marker.global_position, marker_target_position, 10 * delta)
		
