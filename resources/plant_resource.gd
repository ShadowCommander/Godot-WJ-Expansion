extends Node
class_name PlantResource

@export var display_name: String
@export var maturation_time: float
@export var sprite: Texture
# Dictionary of produce and amount to spawn
@export var produce: Dictionary[ProduceResource, int]
