extends Node

const CELL_ID = 2

@export var grid: GridMap
@export var ground_grid: GridMap

# Seconds per tile spread
@export var spread_delay = 1.0

var spread_time: int = INF
var tiles_to_spread_to: Array[Vector3i]

func _ready() -> void:
	spread_time = Time.get_ticks_msec()
	append_all_tiles_to_spread_to()

func _physics_process(delta: float) -> void:
	spread()


func append_all_tiles_to_spread_to() -> void:
	var cells_with_lichen = grid.get_used_cells_by_item(CELL_ID)
	for cell in cells_with_lichen:
		append_adjacent_tiles_to_spread_to(cell)
	tiles_to_spread_to.shuffle()

var cells_to_check = [
	Vector3i(1, 0, 0),
	Vector3i(-1, 0, 0),
	Vector3i(0, 0, 1),
	Vector3i(0, 0, -1),
]

func append_adjacent_tiles_to_spread_to(cell: Vector3i) -> void:
	var cells: Array[Vector3i] = []
	for adjacent in cells_to_check:
		if grid.get_cell_item(cell + adjacent) != CELL_ID and ground_grid.get_cell_item(cell + adjacent) != GridMap.INVALID_CELL_ITEM:
			cells.append(cell + adjacent)
	for c in cells:
		#if grid.get_cell_item(c) == CELL_ID:
			#print("ERROR: ", c)
		if tiles_to_spread_to.has(c):
			continue
		tiles_to_spread_to.append(c)

func spread() -> void:
	if not is_node_ready():
		return
	if Time.get_ticks_msec() < spread_time:
		return
	spread_time += spread_delay * 1000
	var cell = tiles_to_spread_to.pop_front()
	if cell == null:
		return
	grid.set_cell_item(cell, CELL_ID)
	append_adjacent_tiles_to_spread_to(cell)
