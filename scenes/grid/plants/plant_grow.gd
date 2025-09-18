extends AnimatedSprite3D
class_name Plant

@export var plant_resource: PlantResource:
	set(value):
		plant_resource = value
		sprite_frames = plant_resource.sprite_frames
		

var growth_timer: float
var harvestable: bool = false

	
func _ready() -> void:
	growth_timer = plant_resource.maturation_time
	set_growth_frame()

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
	print("weight: %0.2f, lerp: %0.2f, life stage: %d" % [value, lerped, life_stage])
	if life_stage == 0:
		harvestable = true
	frame = life_stage
