extends Component
class_name LichenSpreaderComponent

var pattern_advance_time: int = -1

var pattern_index: int = 0
# List of patterns of cells to replace. Array[Array[Vector3i]]
@export var patterns: Array[Array] = [
#o
	[
		Vector3i(0, 0, 0),
	],

#-o-
#o=o
#-o-
	[
		Vector3i(1, 0, 0),
		Vector3i(0, 0, 1),
		Vector3i(-1, 0, 0),
		Vector3i(0, 0, -1),
	],

#--o--
#-o=o-
#o===o
#-o=o-
#--o--
	[
		Vector3i(2, 0, 0),
		Vector3i(1, 0, 1),
		Vector3i(0, 0, 2),
		Vector3i(-1, 0, 1),
		Vector3i(-2, 0, 0),
		Vector3i(-1, 0, -1),
		Vector3i(0, 0, -2),
		Vector3i(1, 0, -1),
	],

#-o=o-
#o===o
#=====
#o===o
#-o=o-
	[
		Vector3i(2, 0, 1),
		Vector3i(1, 0, 2),
		Vector3i(-1, 0, 2),
		Vector3i(-2, 0, 1),
		Vector3i(-2, 0, -1),
		Vector3i(-1, 0, -2),
		Vector3i(1, 0, -2),
		Vector3i(2, 0, -1),
	],

#--ooo--
#-o===o-
#o=====o
#o=====o
#o=====o
#-o===o-
#--ooo--
	[
		Vector3i(3, 0, 0),
		Vector3i(3, 0, 1),
		Vector3i(2, 0, 2),
		Vector3i(1, 0, 3),
		Vector3i(0, 0, 3),
		Vector3i(-1, 0, 3),
		Vector3i(-2, 0, 2),
		Vector3i(-3, 0, 1),
		Vector3i(-3, 0, 0),
		Vector3i(-3, 0, -1),
		Vector3i(-2, 0, -2),
		Vector3i(-1, 0, -3),
		Vector3i(0, 0, -3),
		Vector3i(1, 0, -3),
		Vector3i(2, 0, -2),
		Vector3i(3, 0, -1),
	],
]

# Spread time in milliseconds
var spread_delay: Array[int] = [
	1000,
	1000,
	1000,
	1000,
	1000,
]

var stopped: bool = false

func _ready() -> void:
	entity.plant_matured.connect(on_plant_matured)

func on_plant_matured() -> void:
	entity.cells_affected.append_array(patterns[pattern_index])

func advance_index() -> void:
	if pattern_index >= patterns.size() - 1:
		stopped = true
		return
	pattern_index += 1
	if pattern_advance_time == -1:
		pattern_advance_time = Time.get_ticks_msec()
	pattern_advance_time += spread_delay[pattern_index]
	entity.cells_affected.append_array(patterns[pattern_index])
	entity.cells_updated.emit()
