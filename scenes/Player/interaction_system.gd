extends Node



@export var look_absolute: GUIDEAction
@export var look_relative: GUIDEAction

@export var player: CharacterBody3D
@export var selection_highlight: MeshInstance3D

@onready var plant_grid_system: PlantGridSystem = $"../PlantGridSystem"

var max_distance: float = 1.5

func _process(delta: float) -> void:
	
	if not is_node_ready():
		return
	var target: Vector3 = look_absolute.value_axis_3d
	if look_absolute.is_triggered():
		target = look_absolute.value_axis_3d
	
	# Get grid square and position cursor highlight
	var grid_selection: AABB = plant_grid_system.get_cell_aabb(target)
	var pos = Vector3(grid_selection.position.x + (grid_selection.size.x / 2), 0.0001, grid_selection.position.z + (grid_selection.size.z / 2))
	selection_highlight.global_position = pos
	#selection_highlight.reset_physics_interpolation()

func get_tile_toward_mouse() -> Vector2i:
	return Vector2i.ZERO
	# On mouse move
	# Get direction of mouse on the world
	# Clamp direction vector to max distance
	# Get the tile on the point
	# Return the tile

# On click
# Interact with the tile that is highlighted
