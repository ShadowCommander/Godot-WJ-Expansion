extends Node

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
	
	# Update cooldown UI
	var time_remaining = plant_cooldown_time - (Time.get_ticks_msec() / 1000.0 - last_plant_time)
	if cooldown_label and time_remaining > 0:
		cooldown_label.text = "Cooldown: %.1fs" % time_remaining
	elif cooldown_label:
		cooldown_label.text = "Ready to plant"

func highlight_hovered_tile(pos: Vector3) -> void:
	highlighted_cell = plant_grid_system.get_cell(pos)
	var highlighted_pos: Vector3 = plant_grid_system.get_cell_center(highlighted_cell)
	selection_highlight.global_position = highlighted_pos

const ZEN_PLANT = preload("uid://b6xi6g65y2i8j")
const DECAY_PLANT = preload("uid://dt6vj0gnyh77c")

func on_interact() -> void:
	var time_since_last_plant = Time.get_ticks_msec() / 1000.0 - last_plant_time
	if time_since_last_plant < plant_cooldown_time:
		return
	
	plant_grid_system.plant(DECAY_PLANT, highlighted_cell)
	last_plant_time = Time.get_ticks_msec() / 1000.0

func on_harvest() -> void:
	var produce_list = plant_grid_system.harvest(highlighted_cell)
	for produce_resource: ProduceResource in produce_list:
		var amount = produce_list[produce_resource]
		%ShopPanelContainer.add_item(produce_resource.id, amount)
