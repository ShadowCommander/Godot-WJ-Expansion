extends CanvasLayer

@export var shop_menu: PanelContainer
@export var toggle_shop: GUIDEAction

func _ready() -> void:
	toggle_shop.triggered.connect(on_toggle_shop)

func on_toggle_shop() -> void:
	shop_menu.visible = !shop_menu.visible
