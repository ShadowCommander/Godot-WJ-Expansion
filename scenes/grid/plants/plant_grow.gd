extends AnimatedSprite3D
class_name Plant

signal plant_matured
signal cells_updated

@export var plant_resource: PlantResource:
	set(value):
		plant_resource = value
		sprite_frames = plant_resource.sprite_frames
		

var growth_timer: float
var mature: bool = false

var cell: Vector3i
var cells_affected: Array[Vector3i]
	
func _ready() -> void:
	growth_timer = plant_resource.maturation_time
	set_growth_frame()
	frame_changed.connect(on_frame_changed)
	cells_affected = plant_resource.affected_tiles

# Growth goes from max_life_stages to 0
# Growth stages lerp from the seed, life stages, then fully mature at 0

func _physics_process(delta: float) -> void:
	if growth_timer <= 0:
		return
	growth_timer -= delta
	set_growth_frame()

func set_growth_frame() -> void:
	var value = (growth_timer / plant_resource.maturation_time)
	var frame_count = sprite_frames.get_frame_count("default")
	var lerped = lerp(0, frame_count - 1, value)
	var life_stage = ceil(lerped)

	if life_stage == 0:
		mature = true
		plant_matured.emit()
	frame = life_stage

func on_frame_changed() -> void:
	if material_override is ShaderMaterial:
		material_override.set_shader_parameter("tex", sprite_frames.get_frame_texture(animation, frame))
