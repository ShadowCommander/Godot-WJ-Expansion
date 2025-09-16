extends CanvasLayer

@export var shop_menu: PanelContainer
@export var inventory_menu: PanelContainer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()
	elif event.is_action_pressed("interact"):
		toggle_shop()

func toggle_inventory() -> void:
	if shop_menu.visible:
		shop_menu.visible = false
	inventory_menu.visible = !inventory_menu.visible

func toggle_shop() -> void:
	if inventory_menu.visible:
		inventory_menu.visible = false
	shop_menu.visible = !shop_menu.visible
