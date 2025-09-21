extends Node
const SELECTION_HIGHLIGHT = preload("uid://bgn5ohxg5pg0k")
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
	highlight_pool.set_pooled_node(SELECTION_HIGHLIGHT)
	highlight_pool.container = highlight_container
func _process(delta: float) -> void:
	if not is_node_ready():
		return
		
	var target: Vector3 = look_absolute.value_axis_3d
	if look_absolute.is_triggered():
		target = look_absolute.value_axis_3d
	target.y = 0
	
	highlight_hovered_tile(target)
	
	var time_remaining = plant_cooldown_time - (Time.get_ticks_msec() / 1000.0 - last_plant_time)
	if cooldown_label:
		if time_remaining > 0:
			cooldown_label.text = "%.1fs" % time_remaining
		else:
			cooldown_label.text = "Ready"
func highlight_hovered_tile(pos: Vector3) -> void:
	highlighted_cell = plant_grid_system.get_cell(pos)
	var highlighted_pos: Vector3 = plant_grid_system.get_cell_center(highlighted_cell)
	highlighted_pos.y = 0.0
	selection_highlight.global_position = highlighted_pos
	
	if highlighted_cell == old_highlight:
		return
	old_highlight = highlighted_cell
	
	var plant = plant_grid_system.get_plant(highlighted_cell)
	var cells = lichen_system.get_cells(plant)
	for node in highlight_pooled_nodes:
		highlight_pool.set_pooled_active(node, false)
	highlight_pooled_nodes.clear()
	cells.erase(highlighted_cell)
	for cell in cells:
		var node: Node3D = highlight_pool.get_pooled()
		highlight_pooled_nodes.append(node)
		node.global_position = plant_grid_system.get_cell_center(cell)
		node.reset_physics_interpolation()
func get_tile_toward_mouse() -> Vector2i:
	return Vector2i.ZERO
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
