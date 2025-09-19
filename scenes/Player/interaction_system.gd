extends Node



@export var look_absolute: GUIDEAction
@export var look_relative: GUIDEAction
@export var interact: GUIDEAction
@export var harvest: GUIDEAction

@export var player: CharacterBody3D
@export var selection_highlight: MeshInstance3D

@onready var plant_grid_system: PlantGridSystem = $"../PlantGridSystem"

@export var max_distance: float = 1.5

var highlighted_cell: Vector3i = Vector3i.ZERO

func _ready() -> void:
	interact.triggered.connect(on_interact)
	harvest.triggered.connect(on_harvest)


func _process(delta: float) -> void:
	if not is_node_ready():
		return
	var target: Vector3 = look_absolute.value_axis_3d
	if look_absolute.is_triggered():
		target = look_absolute.value_axis_3d
	target.y = 0
	
	highlight_hovered_tile(target)

func highlight_hovered_tile(pos: Vector3) -> void:
	# Get grid square and position cursor highlight
	highlighted_cell = plant_grid_system.get_cell(pos)
	
	var highlighted_pos: Vector3 = plant_grid_system.get_cell_center(highlighted_cell)
	selection_highlight.global_position = highlighted_pos
	#selection_highlight.reset_physics_interpolation() # Prevents slidey physics interpolation when positioning the highlight
	
	# TODO Highlight the plant on the tile
	#var plant = plant_grid_system.get_plant(highlighted_cell)
	#if plant != null:
		#pass

func get_tile_toward_mouse() -> Vector2i:
	return Vector2i.ZERO
	# On mouse move
	# Get direction of mouse on the world
	# Clamp direction vector to max distance
	# Get the tile on the point
	# Return the tile

# On click
# Interact with the tile that is highlighted

#region Interact
const ZEN_PLANT = preload("uid://b6xi6g65y2i8j")


func on_interact() -> void:
	plant_grid_system.plant(ZEN_PLANT, highlighted_cell)

func on_harvest() -> void:
	var plant = plant_grid_system.harvest(highlighted_cell)
	if plant == null:
		return
	for produce_resource: ProduceResource in plant.plant_resource.produce:
		var amount = plant.plant_resource.produce[produce_resource]
		%ShopPanelContainer.add_item(produce_resource.id, amount)
	plant.queue_free()
	
#endregion
