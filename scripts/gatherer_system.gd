extends Node

const GATHERER_PARTICLE = preload("uid://cq7mhxujrq6y2")

@export var lichen_system: LichenGridSystem
@export var lichen_grid: GridMap
@export var particle_container: Node3D


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
	var cell = lichen_system.get_cells(comp.entity).pick_random()
	if cell == null:
		return
	var particle: GathererParticle = GATHERER_PARTICLE.instantiate()
	particle.start = comp.entity.global_position
	particle.target = lichen_grid.map_to_local(cell)
	particle_container.add_child(particle)
