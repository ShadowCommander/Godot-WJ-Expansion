class_name NodePool
extends Node

@export var pooled_scene: PackedScene
@export var container: Node3D
@export var initial_pool_size: int = 10

var pool: Array[Node] = []
var pool_size: int = 0
var index: int = 0
var active_counter: Array[int] = [0]

func _ready() -> void:
	increase_pool_size(initial_pool_size)

func increase_pool_size(size: int) -> void:
	pool_size += size
	for i in size:
		var node: Node = pooled_scene.instantiate()
		pool.append(node)
		set_pooled_active(node, false, false)
		container.add_child(node)

func get_pooled() -> Node:
	if pool.is_empty():
		increase_pool_size(1)
	var node: Node = pool[index]
	if node.is_processing() and node.visible:
		index = pool_size + 1
		increase_pool_size(100)
		node = pool[index]
	index = wrapi(index + 1, 0, pool_size - 1) # Pool creates nodes in a circular pool, so this works better with nodes that have a time limit.
	set_pooled_active(node, true)
	return node

func set_pooled_active(node: Node, value: bool, increment_counter: bool = true) -> void:
	# Turning off processing and hiding the rendering is faster than queue_free.
	node.set_process(value)
	node.set_physics_process(value)
	if value:
		node.show()
		if increment_counter:
			active_counter[0] += 1
	else:
		node.hide()
		if increment_counter:
			active_counter[0] -= 1

func set_pooled_node(scene: PackedScene) -> void:
	pooled_scene = scene
