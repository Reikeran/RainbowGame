extends Student

@export var Puddle : PackedScene
@export var AttackDelay : float
var ActionOrder:int = 0
func _Attack():
	var inst = Puddle.instantiate()
	inst.global_position = $CollisionShape2D/PuddleSpawn.global_position
	get_tree().current_scene.add_child(inst)
	
func _start_attacks():
	isAttacking = true
	$AnimatedSprite2D.play("Attack")
	await _AttackAction()

func _AttackAction():
	_Attack()
	AudioManager.PlayBookthrow()
	await get_tree().create_timer(AttackDelay).timeout
	isAttacking = false


func _Action(delta):
	if (TargetPosition - global_position).length() == 0 && !isAttacking :
		$AnimatedSprite2D.play("Idle")
	TimeAccumulator += delta
	if TimeAccumulator >= randf_range(MoveIntervalMin,MoveIntervalMax):
		TimeAccumulator = 0.0
		if ActionOrder == 0:
			call_deferred("_start_attacks")
		else:
			TimeAccumulator = 1.0
			_pickNewTarget()
		ActionOrder = 1 - ActionOrder
	_Move(delta)
