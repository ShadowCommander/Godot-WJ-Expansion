extends Node

@export var resource_directory: String = "res://resources/data/plants"

@onready var plant_grid_system: PlantGridSystem = $"../PlantGridSystem"

var delay: float = 8.0
var time: float = INF

var plants: Array = []

func _ready() -> void:
	time = Time.get_ticks_msec()
	var dir_contents: PackedStringArray = ResourceLoader.list_directory(resource_directory)
	for file: String in dir_contents:
		if file.ends_with("/"):
			continue
		plants.append(ResourceLoader.load(resource_directory + "/" + file))


func _physics_process(delta: float) -> void:
	tick_planting(delta)
	
func tick_planting(delta: float) -> void:
	if not is_node_ready():
		return
	if Time.get_ticks_msec() < time:
		return
	time += delay * 1000
	
	if plants.size() <= 0:
		return
	var plant = plants.pick_random()
	var cell = plant_grid_system.get_plantable_cell()
	plant_grid_system.plant(plant, cell)
