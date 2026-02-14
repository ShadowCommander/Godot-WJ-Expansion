extends Node

const LICHEN_CELL_ID = 2


@export var lichen_grid: GridMap
@export var particle_container: Node3D

var timeline: Dictionary[Plant, int] = {}
var plant_spread: Dictionary[Plant, Array]

var plants: Array[LichenSpreaderComponent] = []

var queued_spread = []

var adjacent_cells = [
	Vector3i(1, 0, 0),
	Vector3i(-1, 0, 0),
	Vector3i(0, 0, 1),
	Vector3i(0, 0, -1),
]

const LICHEN_PARTICLE = preload("uid://8d1snc65k4j5")

func get_all_plant_components() -> Array[LichenSpreaderComponent]:
	var comps = get_tree().get_nodes_in_group("LichenSpreaders")
	var out: Array[LichenSpreaderComponent] = []
	for lsc in comps:
		if lsc is not LichenSpreaderComponent:
			continue
		out.append(lsc)
	return out

func _physics_process(delta: float) -> void:
	var cur = Time.get_ticks_msec()
	for plant: LichenSpreaderComponent in get_all_plant_components():
		if plant.stopped:
			continue
		if not (plant.entity as Plant).mature:
			continue
		if cur < plant.pattern_advance_time:
			continue
		spread_lichen(plant)
		plant.advance_index()

func spread_lichen(plant: LichenSpreaderComponent) -> void:
	for offset in plant.patterns[plant.pattern_index]:
		var cell = plant.cell + offset
		var particle: LichenParticle = LICHEN_PARTICLE.instantiate()
		particle.start = plant.entity.global_position
		particle.target = lichen_grid.map_to_local(cell)
		particle_container.add_child(particle)
		lichen_grid.set_cell_item(cell, LICHEN_CELL_ID)

func can_spread(cell: Vector3i) -> bool:
	# Is cell within range of a plant
	# Is cell adjacent to another lichen cell?
	return true

# Each plant has an independent spread
