extends CanvasLayer

@export var inventory_menu: PanelContainer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_inventory() -> void:
	inventory_menu.visible = !inventory_menu.visible
