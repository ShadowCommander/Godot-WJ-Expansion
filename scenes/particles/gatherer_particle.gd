extends Sprite3D
class_name GathererParticle

var start: Vector3
var target: Vector3
var floor: float = 0
var height: float = 0.2
var time: float = 0.0
var total_time: float = 3.0

func _ready() -> void:
	height += randf_range(-0.1, 0.1)
	total_time += randf_range(-0.5, 0.5)

func _physics_process(delta: float) -> void:
	time += delta
	global_position = get_parabola_position()
	if time > total_time:
		queue_free()


func get_parabola_position() -> Vector3:
	var p = time / total_time
	var ret: Vector3
	
	ret.x = start.x + (target.x - start.x) * p;
	ret.y = floor + (height - floor) * (4 * p - 4 * p * p)
	ret.z = start.z + (target.z - start.z) * p;
	return ret
