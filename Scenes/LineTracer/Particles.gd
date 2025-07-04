extends Node2D

@onready var particles = $CPUParticles2D
var last_mouse_pos = Vector2.ZERO

func _ready():
	last_mouse_pos = get_viewport().get_mouse_position()
	particles.emitting = false

	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.RED)
	gradient.add_point(0.2, Color.ORANGE)
	gradient.add_point(0.3, Color.YELLOW)
	gradient.add_point(0.4, Color.GREEN)
	gradient.add_point(0.6, Color.BLUE)
	gradient.add_point(1.0, Color.PURPLE)

	particles.color_ramp = gradient

func _process(delta):
	var current_mouse_pos = get_viewport().get_mouse_position()
	var mouse_velocity = current_mouse_pos - last_mouse_pos

	particles.global_position = current_mouse_pos

	if Input.is_action_pressed("MouseClickDown"):
		if mouse_velocity.length() > 0:
			particles.direction = -mouse_velocity.normalized()
		particles.emitting = true
	else:
		particles.emitting = false

	last_mouse_pos = current_mouse_pos
