extends Node
class_name PlantGridSystem

const LICHEN_INDEX: int = 2

var plant_grid: Dictionary[Vector3i, Plant]

@export var grid_map: GridMap
@export var plant_container: Node3D

func can_plant(cell: Vector3i) -> bool:
	# Check if pos is lichen on GridMap
	if grid_map.get_cell_item(cell) != LICHEN_INDEX:
		return false
	
	# Check if pos has no plant
	if plant_grid.has(cell):
		return false
	
	return true

#region Get cell

func get_cell(pos: Vector3) -> Vector3i:
	return grid_map.local_to_map(grid_map.to_local(pos))

func get_cell_aabb(cell: Vector3i) -> AABB:
	var grid_size: Vector3 = grid_map.cell_size
	var cell_position = grid_map.global_position + (grid_size * (cell as Vector3))
	return AABB(cell_position, grid_size)

@onready var half_cell_size: = Vector3(grid_map.cell_size.x, 0, grid_map.cell_size.z) / 2

func get_cell_center(cell: Vector3i) -> Vector3:
	var center: Vector3 = grid_map.global_position + (grid_map.cell_size * (cell as Vector3)) + half_cell_size
	return center

#endregion

#region Interaction

const PLANT = preload("uid://dufdya5b5ivea") # TODO Replace with hotbar and seeds from inventory

func plant(plant_resource: PlantResource, cell: Vector3i) -> void:
	if not can_plant(cell):
		return
	print(plant_resource, cell)
	var plant: Plant = PLANT.instantiate()
	plant.plant_resource = plant_resource
	plant_grid[cell] = plant
	plant_container.add_child(plant)
	plant.global_position = get_cell_center(cell)

#endregion
