extends CharacterBody3D

@export var speed: float = 5.0

@export var sprite: AnimatedSprite3D

@export var move: GUIDEAction

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	input_dir = basis * move.value_axis_3d
	input_dir = input_dir / max(1.0, input_dir.length())  
	velocity = input_dir * speed
	
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
