extends Area2D
var last_mouse_pos: Vector2 = Vector2.ZERO
var particle: GPUParticles2D

func _ready():
	particle = $GPUParticles2D  # or preload and instance if needed
	last_mouse_pos = get_viewport().get_mouse_position()

func _process(_delta):
	var current_mouse = get_viewport().get_mouse_position()
	var velocity = current_mouse - last_mouse_pos

	if velocity.length() > 1:  # avoid noise
		var direction = -velocity.normalized()  # invert direction
		var angle = direction.angle()

		# Position the particle emitter at mouse position
		particle.global_position = current_mouse

		# Rotate the particle to face opposite of motion
		particle.rotation = angle

		# Emit once in that direction
		particle.emitting = false
		particle.restart()
		particle.emitting = true

	last_mouse_pos = current_mouse
