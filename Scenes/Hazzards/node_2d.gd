extends Area2D

@export var speed: float
@export var RotationSpeed: float
var velocity: Vector2 = Vector2.ZERO
func _process(delta: float) -> void:
	$Sprite2D.rotation+= RotationSpeed*delta
	position += velocity * delta
	var screen_rect = get_viewport().get_visible_rect()
	if not screen_rect.has_point(global_position):
		queue_free()

func Projectile(direction: Vector2):
	velocity = direction.normalized() * speed
