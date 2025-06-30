extends Node2D
signal OnPolygonCreated(damage:float,area:PackedVector2Array)
signal OnDamageTaken(damage:float)

var LineVector : Line2D
var Drawing : bool = false
var LastPoint : Vector2
var RedrawPoint: int
var collisionVectorList : PackedVector2Array
var Hp : float
var DamageDone : float
@export var MaxHp : float
@export var DistanceBetweeenPoints : float
@export var MaxLineDistance : int
@export var BaseDamage: float 

func _ready() -> void:
	Hp = MaxHp
	LineVector = $Line2D
	DamageDone = BaseDamage

func _process(_delta):
	if Input.is_action_just_pressed("MouseClickDown"):
		_BeginDraw()
	
	_MouseDragDraw()
	
	if Input.is_action_just_released("MouseClickDown"):
		_EndDrawing()



func _MouseDragDraw():
	if Drawing &&_CheckDrawCondition():
		var FromPoint : Vector2 = LastPoint
		var ToPoint : Vector2 = get_global_mouse_position()
		var TotalDistance : float = FromPoint.distance_to(ToPoint)
		var Direction : Vector2 = (ToPoint-FromPoint).normalized()
		var Steps : int = int(TotalDistance/MaxLineDistance)
		
		for i in range(1,Steps + 1):
			var IntermediatePoint = FromPoint + Direction * MaxLineDistance * i
			LineVector.add_point(IntermediatePoint)
			_LimitLineLenght()
			_ReshapeLineOnColition(_LineIntersect())
		LastPoint = ToPoint
		if fmod(TotalDistance, MaxLineDistance) != 0:
			LineVector.add_point(ToPoint)
			LastPoint = ToPoint
			_LimitLineLenght()
			_ReshapeLineOnColition(_LineIntersect())
			
			#collision part
			ClearCollission(false)
			DrawCollission()
			$mouseArea.position = get_global_mouse_position()

func DrawCollission():
	for i in range(LineVector.get_point_count() - 1):
				var start = LineVector.get_point_position(i)
				var end =LineVector.get_point_position(i+1)
			# Create a new CollisionShape2D node
				var collision = CollisionShape2D.new()
				var segment_shape = SegmentShape2D.new()
				segment_shape.a = start
				segment_shape.b = end
				collision.shape = segment_shape    
				collision.position = Vector2.ZERO
				$Area2D.add_child(collision)

func ClearCollission(onlyFirst : bool):
	for child in $Area2D.get_children():
		if child is CollisionShape2D:
			child.queue_free()
		if onlyFirst:
			return

func _LimitLineLenght():
	if Drawing && LineVector.get_point_count() > MaxLineDistance:
		LineVector.remove_point(0)
		ClearCollission(true)
	if Drawing:
		LastPoint = LineVector.get_point_position(LineVector.points.size()-1)

func _CheckDrawCondition():
	var  distance : Vector2 
	distance =  get_global_mouse_position() - LastPoint
	if distance.length() >= DistanceBetweeenPoints:
		return true
	else:
		return false


func _BeginDraw():
	LineVector.add_point(get_global_mouse_position())
	LastPoint = LineVector.get_point_position(LineVector.get_point_count()-1)
	Drawing = true
	$mouseArea.position = get_global_mouse_position()


func _EndDrawing():
	LineVector.clear_points()
	ClearCollission(false)
	LastPoint = Vector2.ZERO
	Drawing = false
	DamageDone = BaseDamage
	$mouseArea.position = Vector2(1000, 1000)

func _LineIntersect() -> Vector2:
	if LineVector.get_point_count() < 2:
		return Vector2.ZERO
	var CollisionPoint: Vector2 = Vector2.ZERO
	var FinalPoint: Vector2 = LastPoint
	var PreviousToFinal: Vector2 = LineVector.get_point_position(LineVector.get_point_count() - 2)
	var LoopIndex: int = 2
	while LoopIndex < LineVector.get_point_count() - 1:
		var i = LineVector.get_point_count() - LoopIndex - 1
		var ComparisonStart: Vector2 = LineVector.get_point_position(i)
		var ComparisonEnd: Vector2 = LineVector.get_point_position(i + 1)
		if ComparisonEnd == PreviousToFinal:
			LoopIndex += 1
			continue
		var result: Variant = Geometry2D.segment_intersects_segment(PreviousToFinal, FinalPoint, ComparisonStart, ComparisonEnd)
		if result != null:
			CollisionPoint = result
			RedrawPoint = i
			print("Collision at: ", CollisionPoint)
			break
		LoopIndex += 1
	return CollisionPoint


func _ReshapeLineOnColition(ColitionPoint : Vector2):
	if ColitionPoint != Vector2.ZERO:
		_AddVectorToColliderList(ColitionPoint)
		for i in range(LineVector.get_point_count()-1,RedrawPoint, -1):
			_AddVectorToColliderList(LineVector.get_point_position(i))
			LineVector.remove_point(i)
		LineVector.add_point(get_global_mouse_position())
		LastPoint = LineVector.get_point_position(LineVector.get_point_count()-1)
		_CircleCreated()
		ClearCollission(false)
		DrawCollission()
			
func _AddVectorToColliderList(point : Vector2):
	collisionVectorList.append(point)
	
func _CircleCreated():
	OnPolygonCreated.emit(DamageDone,collisionVectorList)
	collisionVectorList.clear()
	DamageDone+=5
	
func TakeDamage(damageTaken : float):
	Hp -= damageTaken
	_EndDrawing()
	OnDamageTaken.emit(damageTaken)


func _on_area_2d_area_entered(area: Area2D) -> void:
	AudioManager.PlayCrashSFX()
	if area.collision_layer & (1 << 1):
		TakeDamage(0)
	if area.collision_layer & (1 << 2):
		TakeDamage(10)


func _on_mouse_area_area_entered(area: Area2D) -> void:
	AudioManager.PlayCrashSFX()
	if area.collision_layer & (1 << 1):
		TakeDamage(0)
	if area.collision_layer & (1 << 2):
		TakeDamage(10)
