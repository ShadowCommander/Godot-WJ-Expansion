extends Node
const GATHERER_PARTICLE = preload("uid://cq7mhxujrq6y2")
@export var lichen_system: LichenGridSystem
@export var lichen_grid: GridMap
@export var particle_container: Node3D
# Reference to a GameManager or similar singleton that handles fruit
# If you don't have one yet, you might want to create one
@export var construct_system: Node

func get_all_plant_components() -> Array[GathererComponent]:
	var comps = get_tree().get_nodes_in_group("LichenGatherers")
	var out: Array[GathererComponent] = []
	for lsc in comps:
		if lsc is not GathererComponent:
			continue
		out.append(lsc)
	return out

func _physics_process(delta: float) -> void:
	var cur = Time.get_ticks_msec()
	for comp: GathererComponent in get_all_plant_components():
		if not (comp.entity as Plant).mature:
			continue
		if cur < comp.time:
			continue
		gather_lichen(comp)
		comp.update_time()

func gather_lichen(comp: GathererComponent) -> void:
	var cells = lichen_system.get_cells(comp.entity, PlantResource.PlantType.Spreader)
	if cells == null or cells.is_empty():
		return
	
	#print("Cells nearby: ", cells.size())
	#for cell in cells:
		#spawn_particle(cell, comp.entity.global_position)
	
	var cell: Vector3i
	for i in range(1):
		cell = cells.pick_random()
		spawn_particle(cell, comp.entity.global_position)
	
	# Increase Construct fruit counter scaled by number of cells
	var fruit_amount = calculate_fruit_production(cells.size())
	
	if construct_system:
		construct_system.add_fruit(fruit_amount, comp.entity)
	else:
		print("No construct system assigned! Fruit amount would be: ", fruit_amount)

func calculate_fruit_production(cell_count: int) -> int:
	# Scale fruit production based on number of lichen cells
	# You can adjust this formula as needed
	return max(1, cell_count / 5)  # 1 fruit per 5 cells, minimum 1

func spawn_particle(cell: Vector3i, spawn_pos: Vector3) -> void:
	var particle: GathererParticle = GATHERER_PARTICLE.instantiate()
	particle.start = lichen_grid.map_to_local(cell)
	particle.target = spawn_pos
	particle_container.add_child(particle)
