extends CharacterBody3D

@export var speed: float = 5.0

@export var sprite: AnimatedSprite3D

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_front"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()
	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed
	move_and_slide()

	if input_dir == Vector3.ZERO:
		sprite.play("idle")
	elif input_dir.z < 0:
		sprite.play("run_back")
	elif input_dir.z > 0:
		sprite.play("run_front")
	elif input_dir.x != 0:
		sprite.play("run")
		sprite.rotation.y = 180 if input_dir.x > 0 else 0
