extends Node
class_name PlantGridSystem

const MOSS_INDEX: int = 2

var plant_grid: Dictionary[Vector2i, Plant]

@export var grid_map: GridMap

func can_plant(pos: Vector3) -> bool:
	# Check if pos is moss on GridMap
	var cell = grid_map.local_to_map(grid_map.to_local(pos))
	if grid_map.get_cell_item(cell) != MOSS_INDEX:
		return false
	
	# Check if pos has no plant
	if plant_grid.has(cell):
		return false
	
	return true

func get_cell_aabb(pos: Vector3) -> AABB:
	var cell: Vector3 = grid_map.local_to_map(grid_map.to_local(pos))
	var grid_size: Vector3 = grid_map.cell_size
	var cell_position = grid_map.global_position + (grid_size * cell)
	return AABB(cell_position, grid_size)
