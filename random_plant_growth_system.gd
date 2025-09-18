extends Node

@export var resource_directory: String = "res://resources/data/plants"

@onready var plant_grid_system: PlantGridSystem = $"../PlantGridSystem"

var delay: float = 8.0
var time: float = INF

var plants: Array = []

func _ready() -> void:
	time = Time.get_ticks_msec()
	for plant in ResourceLoader.list_directory(resource_directory):
		plants.append(ResourceLoader.load(resource_directory + "/" + plant))


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
	var cell = Vector3(randi_range(-10, 10), 0, randi_range(-10, 10))
	plant_grid_system.plant(plants[0], cell)
