extends Node

const SELECTION_HIGHLIGHT = preload("uid://b04x5fdaew4xq")

@export var look_absolute: GUIDEAction
@export var look_relative: GUIDEAction
@export var interact: GUIDEAction
@export var harvest: GUIDEAction
@export var player: CharacterBody3D
@export var selection_highlight: MeshInstance3D
@onready var plant_grid_system: PlantGridSystem = $"../PlantGridSystem"

@export var plant_cooldown_time: float = 2.0
@export var cooldown_label: Label
var last_plant_time: float = 0.0

@export var lichen_system: LichenGridSystem
@export var highlight_container: Node3D

var highlighted_cell: Vector3i = Vector3i.ZERO
var highlight_pool: NodePool = NodePool.new()
var highlight_pooled_nodes: Array[Node] = []
var old_highlight: Vector3i

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
	
	# Update cooldown UI
	var time_remaining = plant_cooldown_time - (Time.get_ticks_msec() / 1000.0 - last_plant_time)
	if cooldown_label and time_remaining > 0:
		cooldown_label.text = "Cooldown: %.1fs" % time_remaining
	elif cooldown_label:
		cooldown_label.text = "Ready to plant"

func highlight_hovered_tile(pos: Vector3) -> void:
	highlighted_cell = plant_grid_system.get_cell(pos)
	var highlighted_pos: Vector3 = plant_grid_system.get_cell_center(highlighted_cell)
	highlighted_pos.y = 0.0
	selection_highlight.global_position = highlighted_pos
	#selection_highlight.reset_physics_interpolation() # Prevents slidey physics interpolation when positioning the highlight
	
	if highlighted_cell == old_highlight:
		return
	old_highlight = highlighted_cell
	
	var plant = plant_grid_system.get_plant(highlighted_cell)
	var cells = lichen_system.get_cells(plant)
	for node in highlight_pooled_nodes:
		highlight_pool.set_pooled_active(node, false)
	highlight_pooled_nodes.clear()
	for cell in cells:
		var node: Node3D = highlight_pool.get_pooled()
		highlight_pooled_nodes.append(node)
		node.global_position = plant_grid_system.get_cell_center(cell)
		node.reset_physics_interpolation()
		#highlight_container.add_child(node)
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
const DECAY_PLANT = preload("uid://dt6vj0gnyh77c")
const CONSTRUCT_PLANT = preload("uid://3oemwwigbcxh")


func on_interact() -> void:
	var time_since_last_plant = Time.get_ticks_msec() / 1000.0 - last_plant_time
	if time_since_last_plant < plant_cooldown_time:
		return
	
	plant_grid_system.plant(CONSTRUCT_PLANT, highlighted_cell)
	last_plant_time = Time.get_ticks_msec() / 1000.0

func on_harvest() -> void:
	var produce_list = plant_grid_system.harvest(highlighted_cell)
	for produce_resource: ProduceResource in produce_list:
		var amount = produce_list[produce_resource]
		pass
