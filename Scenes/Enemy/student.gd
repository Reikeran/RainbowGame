class_name Student
extends Area2D

signal OnDeath()

@export var MoveIntervalMin: float
@export var MoveIntervalMax: float
@export var MoveSpeed: float
@export var Hp : float 
var TargetPosition: Vector2
var TimeAccumulator: float = 0.0
var isAttacking : bool = false
var isDead : bool = false

func _process(delta):
	if !isDead :
		_Action(delta)
		
func _ready() -> void:
	$ProgressBar.max_value = Hp
	$ProgressBar.value = $ProgressBar.max_value-Hp
	randomize()
	_pickNewTarget()

func _Action(delta):
	if (TargetPosition - global_position).length() == 0 && !isAttacking :
		$AnimatedSprite2D.play("Idle")
	TimeAccumulator += delta
	if TimeAccumulator >= randf_range(MoveIntervalMin,MoveIntervalMax):
		TimeAccumulator = 0.0
		_pickNewTarget()
	_Move(delta)


func _Move(delta):

	var direction = (TargetPosition - global_position).normalized()
	var distance = MoveSpeed * delta
	var toTarget = TargetPosition - global_position

	if toTarget.length() > distance:
		global_position += direction * distance
	else:
		global_position = TargetPosition

func _pickNewTarget():
	var viewportCenter = get_viewport_rect().size / 2
	var halfAreaSize = get_viewport_rect().size * (1.0 / 2.0)
	var randomOffset = Vector2(
		randf_range(-halfAreaSize.x / 2, halfAreaSize.x / 2),
		randf_range(-halfAreaSize.y / 2, halfAreaSize.y / 2)
	)
	TargetPosition = viewportCenter + randomOffset
	_MoveAnim()

func _MoveAnim():
	var direction = (TargetPosition - global_position).normalized()
	var angle_deg = rad_to_deg(direction.angle())
	angle_deg = fposmod(angle_deg, 360)

	if angle_deg >= 45 and angle_deg < 135:
		$AnimatedSprite2D.play("Run_Down")
	elif angle_deg >= 135 and angle_deg < 225:
		$AnimatedSprite2D.play("Run_Left") 
	elif angle_deg >= 225 and angle_deg < 315:
		$AnimatedSprite2D.play("Run_Up")
	else:
		$AnimatedSprite2D.play("Run_Right")

func _TakeDamage(value:float):
	Hp -= value
	LevelManager.ModifyScore(100)
	$ProgressBar.value = $ProgressBar.max_value-Hp
	if Hp <= 0 && !isDead:
		isDead = true
		$AnimatedSprite2D.play("Death")
		await $AnimatedSprite2D.animation_finished
		OnDeath.emit()
		queue_free()

func _on_line_tracer_on_polygon_created(damageReceived: float, area: PackedVector2Array) -> void:
	if Geometry2D.is_point_in_polygon(transform.get_origin(),area):
		AudioManager.PlayLoopSFX()
		_TakeDamage(damageReceived)
