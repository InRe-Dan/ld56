extends Node2D

@onready var leg_targets : Node2D = $LegTargets
@onready var skeleton : Skeleton2D = $Skeleton2D
@onready var raycast : RayCast2D = $RayCast2D

## stolen function
func NearestPointOnLine(start : Vector2, end : Vector2, pnt : Vector2) -> Vector2:
	var lineDir = start.direction_to(end)
	var v = pnt - start;
	var d = v.dot(lineDir)
	if d > start.distance_to(end):
		return Vector2(-1, -1)
	return start + lineDir * d;
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for node : Node2D in leg_targets.get_children():
		var area : Area2D = node.get_node("Area2D")
		var marker : Marker2D = node.get_node("Marker2D")
		var target : Vector2 = node.global_position
		var best_dist = 100000
		if area.has_overlapping_bodies():
			for object : PhysicsBody2D in area.get_overlapping_bodies():
				for object_child : Node in object.get_children():
					print(object_child)
					if object_child is CollisionPolygon2D:
						var points : PackedVector2Array = object_child.polygon
						var closest : Vector2 = NearestPointOnLine(points[0], points[1], node.global_position)
						if closest != Vector2(-1, -1):
							best_dist = closest.distance_to(node.global_position)
							target = closest
							print("1")
		print(target)
		marker.global_position = lerp(marker.global_position, target, 5 * delta)
