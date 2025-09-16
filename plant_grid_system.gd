extends Node

const MOSS_INDEX: int = 2

var plant_grid: Dictionary[Vector2i, Plant]

@onready var grid_map: GridMap = $"../../Node3D/GridMap"

func can_plant(pos: Vector3) -> bool:
	pass
	# Check if pos is moss on GridMap
	var cell = grid_map.local_to_map(grid_map.to_local(pos))
	if grid_map.get_cell_item(cell) != MOSS_INDEX:
		return false
	
	# Check if pos has no plant
	if plant_grid.has(cell):
		return false
	
	return true
