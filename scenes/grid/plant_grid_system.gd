extends Node
class_name PlantGridSystem

const LICHEN_INDEX: int = 2
var plant_grid: Dictionary[Vector3i, Plant]
@export var lichen_grid: GridMap
@export var ground_grid: GridMap
@export var plant_container: Node3D
@export var lichen_system: LichenGridSystem
@export var sprout_duration: float = 1.0

var search_max_loops: int = 1000

#region Plant
func can_plant(cell: Vector3i) -> bool:
	# Check if pos is lichen on GridMap
	if lichen_grid.get_cell_item(cell) != LICHEN_INDEX:
		return false
	
	# Check if pos has no plant
	if plant_grid.has(cell):
		return false
	
	return true

func get_plant(cell: Vector3i) -> Plant:
	return plant_grid.get(cell)

func get_plantable_cell() -> Vector3i:
	var cells = lichen_grid.get_used_cells_by_item(LICHEN_INDEX)
	var i = 0
	var cell = cells.pick_random()
	while plant_grid.has(cell):
		cell = cells.pick_random()
		i += 1
		if i > search_max_loops:
			break
	return cell
#endregion

#region Get cell
func get_cell(pos: Vector3) -> Vector3i:
	return lichen_grid.local_to_map(lichen_grid.to_local(pos))

func get_cell_aabb(cell: Vector3i) -> AABB:
	var grid_size: Vector3 = lichen_grid.cell_size
	var cell_position = lichen_grid.global_position + (grid_size * (cell as Vector3))
	return AABB(cell_position, grid_size)

@onready var half_cell_size: = Vector3(lichen_grid.cell_size.x, 0, lichen_grid.cell_size.z) / 2

func get_cell_center(cell: Vector3i) -> Vector3:
	var center: Vector3 = lichen_grid.global_position + (lichen_grid.cell_size * (cell as Vector3)) + half_cell_size
	return center
#endregion

#region Interaction
const PLANT = preload("uid://dufdya5b5ivea") # TODO Replace with hotbar and seeds from inventory
@onready var planting_pos_rand = half_cell_size * 0.5

## Creates a plant with plant_resource on the provided cell.[br]
## Returns the plant node if spawned, null otherwise.
func plant(plant_resource: PlantResource, cell: Vector3i) -> Plant:
	if not can_plant(cell):
		return null
	
	print(plant_resource, cell)
	var plant: Plant = PLANT.instantiate()
	plant.plant_resource = plant_resource
	plant.cell = cell
	plant_grid[cell] = plant
	plant_container.add_child(plant)
	
	var planting_pos = get_cell_center(cell) + Vector3(randf_range(-planting_pos_rand.x, planting_pos_rand.x), 0, randf_range(-planting_pos_rand.z, planting_pos_rand.z))
	plant.global_position = planting_pos
	plant.plant_matured.connect(on_plant_matured.bind(plant))
	plant.cells_updated.connect(on_cells_updated.bind(plant))
	
	for c: PackedScene in plant.plant_resource.components:
		var comp: Component = c.instantiate()
		comp.entity = plant
		comp.cell = cell
		plant.add_child(comp)
	
	# Add sprouting animation
	animate_sprouting(plant)
	
	return plant

func animate_sprouting(plant_node: Node3D) -> void:
	if not plant_node:
		return
	
	var original_scale = plant_node.scale
	plant_node.scale = Vector3.ZERO
	
	var tween = create_tween()
	tween.tween_property(plant_node, "scale", original_scale, sprout_duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

func harvest(cell: Vector3i) -> Dictionary[ProduceResource, int]:
	if not plant_grid.has(cell):
		return {}
	
	var plant: Plant = plant_grid.get(cell)
	lichen_system.remove_plant_from_cells(plant)
	plant_grid.erase(cell)
	
	var produce = plant.plant_resource.produce
	plant.queue_free()
	
	if not plant.mature:
		return {}
	
	return produce
#endregion

func on_plant_matured(plant: Plant) -> void:
	lichen_system.add_plant_to_cells(plant, plant.cells_affected)
	
func on_cells_updated(plant: Plant) -> void:
	lichen_system.add_plant_to_cells(plant, plant.cells_affected)
