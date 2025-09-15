extends Node

@export var plant_resource: PlantResource

var growth_timer: float
var harvestable: bool = false

func _ready() -> void:
	growth_timer = plant_resource.maturation_time

# Growth goes from max_life_stages to 0
# Growth stages lerp from the seed, life stages, then fully mature at 0

func _physics_process(delta: float) -> void:
	if growth_timer <= 0:
		return
	growth_timer -= delta
	var value = (growth_timer / plant_resource.maturation_time)
	var lerped = lerp(0, 3, value)
	var life_stage = ceil(lerped)
	print("weight: %0.2f, lerp: %0.2f, life stage: %d" % [value, lerped, life_stage])
	if life_stage == 0:
		harvestable = true
	
