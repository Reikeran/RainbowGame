extends Student

@export var BookProjectile : PackedScene
@export var Attacks : int
@export var AttackDelay : float


func _Attack():
	var inst = BookProjectile.instantiate()
	inst.position = transform.get_origin()
	inst.Projectile(getRandomDirection())
	get_tree().current_scene.add_child(inst)
	
func _start_attacks():
	isAttacking = true
	$AnimatedSprite2D.play("Attack")
	await _AttackAction()

func _AttackAction():
	for i in range(Attacks):
		_Attack()
		AudioManager.PlayBookthrow()
		if i < Attacks-1:
			await get_tree().create_timer(AttackDelay).timeout
		
	isAttacking = false
func getRandomDirection() -> Vector2:
	var random_angle = randf_range(0, TAU)  
	return Vector2.RIGHT.rotated(random_angle)

func _Action(delta):
	if (TargetPosition - global_position).length() == 0 && !isAttacking :
		$AnimatedSprite2D.play("Idle")
	TimeAccumulator += delta
	if TimeAccumulator >= randf_range(MoveIntervalMin,MoveIntervalMax):
		TimeAccumulator = 0.0
		var rand : int = randi_range(1,5)
		if rand == 4:
			call_deferred("_start_attacks")
		else:
			_pickNewTarget()
	_Move(delta)
