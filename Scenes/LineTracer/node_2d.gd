extends Node2D

signal OnPolygonCreated(damage: float, area: PackedVector2Array)
signal OnDamageTaken(damage: float)

@export var MaxHp: float = 100.0
@export var DistanceBetweenPoints: float = 10.0
@export var MaxLineDistance: int = 100
@export var BaseDamage: float = 10.0

var LineVector: Line2D
var Drawing: bool = false
var LastPoint: Vector2
var RedrawPoint: int
var collisionVectorList: PackedVector2Array = PackedVector2Array()
var Hp: float
var DamageDone: float

func _ready() -> void:
	Hp = MaxHp
	LineVector = $Line2D
	DamageDone = BaseDamage

	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if enemy.has_method("_on_line_tracer_on_polygon_created"):
			connect("OnPolygonCreated", Callable(enemy, "_on_line_tracer_on_polygon_created"))

	var root = get_tree().get_current_scene()
	if root:
		var hud = root.get_node_or_null("Control")
		if hud and hud.has_method("_on_line_tracer_on_damage_taken"):
			connect("OnDamageTaken", Callable(hud, "_on_line_tracer_on_damage_taken"))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MouseClickDown"):
		_BeginDraw()

	_MouseDragDraw()

	if Input.is_action_just_released("MouseClickDown"):
		_EndDrawing()

func _MouseDragDraw() -> void:
	if Drawing and _CheckDrawCondition():
		var from_point = LastPoint
		var to_point = get_global_mouse_position()
		var total_distance = from_point.distance_to(to_point)
		var direction = (to_point - from_point).normalized()
		var steps = int(total_distance / MaxLineDistance)

		for i in range(1, steps + 1):
			var intermediate_point = from_point + direction * MaxLineDistance * i
			LineVector.add_point(intermediate_point)
			_LimitLineLength()
			_ReshapeLineOnCollision(_LineIntersect())

		LastPoint = to_point
		if fmod(total_distance, MaxLineDistance) != 0:
			LineVector.add_point(to_point)
			LastPoint = to_point
			_LimitLineLength()
			_ReshapeLineOnCollision(_LineIntersect())

		ClearCollision(false)
		DrawCollision()
		$mouseArea.position = get_global_mouse_position()

func DrawCollision() -> void:
	for i in range(LineVector.get_point_count() - 1):
		var start = LineVector.get_point_position(i)
		var end = LineVector.get_point_position(i + 1)

		var collision = CollisionShape2D.new()
		var segment_shape = SegmentShape2D.new()
		segment_shape.a = start
		segment_shape.b = end
		collision.shape = segment_shape
		collision.position = Vector2.ZERO
		$Area2D.add_child(collision)

func ClearCollision(only_first: bool) -> void:
	for child in $Area2D.get_children():
		if child is CollisionShape2D:
			child.queue_free()
			if only_first:
				return

func _LimitLineLength() -> void:
	if Drawing and LineVector.get_point_count() > MaxLineDistance:
		LineVector.remove_point(0)
		ClearCollision(true)

	if Drawing:
		LastPoint = LineVector.get_point_position(LineVector.points.size() - 1)

func _CheckDrawCondition() -> bool:
	return get_global_mouse_position().distance_to(LastPoint) >= DistanceBetweenPoints

func _BeginDraw() -> void:
	LineVector.clear_points()
	collisionVectorList.clear()
	LineVector.add_point(get_global_mouse_position())
	LastPoint = LineVector.get_point_position(LineVector.get_point_count() - 1)
	Drawing = true
	$mouseArea.position = get_global_mouse_position()

func _EndDrawing() -> void:
	LineVector.clear_points()
	ClearCollision(false)
	LastPoint = Vector2.ZERO
	Drawing = false
	DamageDone = BaseDamage
	$mouseArea.position = Vector2(1000, 1000)

func _LineIntersect() -> Vector2:
	if LineVector.get_point_count() < 2:
		return Vector2.ZERO

	var collision_point = Vector2.ZERO
	var final_point = LastPoint
	var prev_to_final = LineVector.get_point_position(LineVector.get_point_count() - 2)
	var loop_index = 2

	while loop_index < LineVector.get_point_count() - 1:
		var i = LineVector.get_point_count() - loop_index - 1
		var comp_start = LineVector.get_point_position(i)
		var comp_end = LineVector.get_point_position(i + 1)

		if comp_end == prev_to_final:
			loop_index += 1
			continue

		var result = Geometry2D.segment_intersects_segment(prev_to_final, final_point, comp_start, comp_end)
		if result:
			collision_point = result
			RedrawPoint = i
			print("Collision at: ", collision_point)
			break

		loop_index += 1

	return collision_point

func _ReshapeLineOnCollision(collision_point: Vector2) -> void:
	if collision_point != Vector2.ZERO:
		_AddVectorToColliderList(collision_point)
		for i in range(LineVector.get_point_count() - 1, RedrawPoint, -1):
			_AddVectorToColliderList(LineVector.get_point_position(i))
			LineVector.remove_point(i)
		LineVector.add_point(get_global_mouse_position())
		LastPoint = LineVector.get_point_position(LineVector.get_point_count() - 1)
		_CircleCreated()
		ClearCollision(false)
		DrawCollision()

func _AddVectorToColliderList(point: Vector2) -> void:
	collisionVectorList.append(point)

func _CircleCreated() -> void:
	OnPolygonCreated.emit(DamageDone, collisionVectorList)

	if collisionVectorList.size() < 3:
		return

	var poly = Polygon2D.new()
	poly.polygon = collisionVectorList
	poly.color = Color(randf(), randf(), randf(), 0.5)
	
	add_child(poly)

	# Fade out over 2 seconds and then remove
	var tween = create_tween()
	tween.tween_property(poly, "modulate:a", 0.0, 0.5)
	tween.tween_callback(Callable(poly, "queue_free"))

	collisionVectorList.clear()
	DamageDone += 5

func TakeDamage(damage_taken: float) -> void:
	Hp -= damage_taken
	_EndDrawing()
	OnDamageTaken.emit(damage_taken)

func _on_area_2d_area_entered(area: Area2D) -> void:
	AudioManager.PlayCrashSFX()
	if area.collision_layer & (1 << 1):
		TakeDamage(0)
	elif area.collision_layer & (1 << 2):
		TakeDamage(10)

func _on_mouse_area_area_entered(area: Area2D) -> void:
	AudioManager.PlayCrashSFX()
	if area.collision_layer & (1 << 1):
		TakeDamage(0)
	elif area.collision_layer & (1 << 2):
		TakeDamage(10)
