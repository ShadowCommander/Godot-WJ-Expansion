extends Node
class_name LichenGridSystem

# 2D array of lichen tiles
# Use this to determine which tiles are supported by Decay
# Use this to determine which tiles are near Construct

# Dictionary[Vector3i, Array[Plant]]
var grid_to_plant: Dictionary[Vector3i, Array] = {}
# Dictionary[Plant, Array[Vector3i]]
var plant_to_grid: Dictionary[Plant, Array] = {}
# Count of plant types on a cell
# Dictionary[Vector3i, Dictionary[PlantType, int]]
var grid_data: Dictionary[Vector3i, Dictionary] = {}

func add_plant_to_cells(plant: Plant, cells: Array[Vector3i]) -> void:
	# Array[Vector3i]
	#var plant_cells: Array = plant_to_grid.get_or_add(plant, [])
	#plant_cells.append_array(cells)
	var offset_cells: Array[Vector3i] = []
	for cell in cells:
		offset_cells.append(cell + plant.cell)
	
	for cell in offset_cells:
		# Check if already contains cell
		var validation = plant_to_grid.get(plant)
		if validation != null and validation.has(cell):
			continue
			
		if plant.plant_resource.type == PlantResource.PlantType.Gatherer:
			# Array[Plant]
			var plants: Array = grid_to_plant.get_or_add(cell, [])
			var plant_to_replace: Plant = null
			var is_other_gatherer: bool = false
			for p in plants:
				if p.plant_resource.type != PlantResource.PlantType.Gatherer:
					continue
				is_other_gatherer = true
				var new_dist = cell.distance_squared_to(plant.cell)
				var old_dist = cell.distance_squared_to(p.cell)
				if new_dist < old_dist:
					plant_to_replace = p
			
			if plant_to_replace != null:
				internal_erase_plant(plant_to_replace, cell)
				internal_insert_plant(plant, cell)
			if is_other_gatherer:
				continue
		internal_insert_plant(plant, cell)

func remove_plant_from_cells(plant: Plant) -> void:
	if not plant_to_grid.has(plant):
		return
	var cells: Array = plant_to_grid.get(plant)
	if cells == null:
		return
	for cell: Vector3i in cells:
		internal_erase_plant(plant, cell)
	plant_to_grid.erase(plant)

#func remove_cell(cell: Vector3i) -> void:
	#var plants: Array[Plant] = grid_to_plant.get(cell)
	#if plants == null:
		#return
	#for plant: Plant in plants:
		#plant_to_grid.get(plant).erase(cell)
	#grid_to_plant.erase(cell)

func internal_erase_plant(plant: Plant, cell: Vector3i) -> void:
	var offset_cell = cell # + plant.cell 
	plant_to_grid[plant].erase(offset_cell)
	if plant_to_grid[plant].size() == 0:
		plant_to_grid.erase(plant)
	grid_to_plant[offset_cell].erase(plant)
	if grid_to_plant[offset_cell].size() == 0:
		grid_to_plant.erase(offset_cell)
	print("grid_to_plant: ", grid_to_plant.get(offset_cell))
	var data: Dictionary = grid_data.get(offset_cell)
	var type = plant.plant_resource.type
	if data == null or not data.has(type):
		return
	var type_count = data.get(type)
	type_count -= 1
	if type_count <= 0:
		data.erase(type)
	else:
		data[plant.plant_resource.type] = type_count

func internal_insert_plant(plant: Plant, cell: Vector3i) -> void:
	var offset_cell = cell # + plant.cell
	if not plant_to_grid.has(plant):
		return
	var cells = plant_to_grid.get_or_add(plant, [])
	if cells.has(offset_cell):
		return
	cells.append(offset_cell)
	grid_to_plant.get_or_add(offset_cell, []).append(plant)
	var data = grid_data.get_or_add(offset_cell, {})
	var type_count = data.get_or_add(plant.plant_resource.type, 0)
	type_count += 1
	data[plant.plant_resource.type] = type_count

func get_cells(plant: Plant, type: PlantResource.PlantType = PlantResource.PlantType.Any) -> Array[Vector3i]:
	if not plant_to_grid.has(plant):
		return []
	var arr: Array = plant_to_grid.get(plant)
	var converted: Array[Vector3i]
	converted.assign(arr)
	
	if type == PlantResource.PlantType.Any:
		return converted
	
	var filtered: Array[Vector3i] = []
	for cell in converted:
		var types: Dictionary = grid_data.get(cell)
		if types == null:
			continue
		if not types.has(type):
			continue
		filtered.append(cell)
	return filtered
