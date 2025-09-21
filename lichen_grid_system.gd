extends Node
class_name LichenGridSystem

# 2D array of lichen tiles
# Use this to determine which tiles are supported by Decay
# Use this to determine which tiles are near Construct

# Dictionary[Vector3i, Array[Plant]]
var grid_to_plant: Dictionary[Vector3i, Array] = {}
# Dictionary[Plant, Array[Vector3i]]
var plant_to_grid: Dictionary[Plant, Array] = {}

func add_plant_to_cells(plant: Plant, cells: Array[Vector3i]) -> void:
	var plant_cells: Array[Vector3i] = plant_to_grid.get_or_add(plant, [])
	plant_cells.append_array(cells)
	
	for cell in cells:
		var plants: Array[Plant] = grid_to_plant.get_or_add(cell)
		if plants.has(plant):
			continue
		if plant.plant_resource.type == PlantResource.PlantType.Gatherer:
			var plant_to_replace: Plant = null
			for p in plants:
				if p.plant_resource.type != PlantResource.PlantType.Gatherer:
					continue
				var new_dist = cell.distance_squared_to(plant.cell)
				var old_dist = cell.distance_squared_to(p.cell)
				if new_dist < old_dist:
					plant_to_replace = p
				break
			
			if plant_to_replace == null:
				continue
			internal_erase_plant(plant_to_replace, cell)
			internal_insert_plant(plant, cell)
			continue
		internal_insert_plant(plant, cell)

func remove_plant_from_cells(plant: Plant) -> void:
	var cells: Array[Vector3i] = plant_to_grid.get(plant)
	if cells == null:
		return
	for cell: Vector3i in cells:
		grid_to_plant.get(cell).erase(plant)
	plant_to_grid.erase(plant)

func remove_cell(cell: Vector3i) -> void:
	var plants: Array[Plant] = grid_to_plant.get(cell)
	if plants == null:
		return
	for plant: Plant in plants:
		plant_to_grid.get(plant).erase(cell)
	grid_to_plant.erase(cell)

func internal_erase_plant(plant: Plant, cell: Vector3i) -> void:
	plant_to_grid[plant].erase(cell)
	grid_to_plant[cell].erase(plant)

func internal_insert_plant(plant: Plant, cell: Vector3i) -> void:
	plant_to_grid.get_or_add(plant, []).append(cell)
	grid_to_plant.get_or_add(cell).append(plant)

func get_cells(plant: Plant) -> Array[Vector3i]:
	if not plant_to_grid.has(plant):
		return []
	var arr: Array[Vector3i] = plant_to_grid.get(plant)
	return arr
