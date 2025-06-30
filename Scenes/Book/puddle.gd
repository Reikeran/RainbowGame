extends Area2D
@export var Duration: float
@export var target_scale: Vector2 = Vector2(0.007, 0.007)
@export var scale_duration: float = 0.33

func _ready():
	scale = Vector2.ZERO  # Start from scale 0
	_start_scale_animation()
	_start_despawn_timer()

func _start_scale_animation():
	var tween := create_tween()
	tween.tween_property(self, "scale", target_scale, scale_duration)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)

func _start_despawn_timer():
	var despawn_timer = Timer.new()
	despawn_timer.wait_time = Duration
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(_on_despawn_timeout)
	add_child(despawn_timer)
	despawn_timer.start()

func _on_despawn_timeout():
	queue_free()
