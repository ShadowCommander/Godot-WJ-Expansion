extends LazyListEntry
class_name MarketLazyListEntry

class MarketEntryData:
	var id: int
	var icon: Texture
	var display_name: String
	var price: int
	
	func _init(id: int, icon: Texture, display_name: String, price: int) -> void:
		self.id = id
		self.icon = icon
		self.display_name = display_name
		self.price = price

@export var icon_texture_rect: TextureRect
@export var name_label: Label
@export var price_label: Label

func configure_item(index: int, data):
	super(index, data)
	
	icon_texture_rect.texture = data.icon
	name_label.text = data.display_name
	price_label.text = "$" + str(data.price)

func set_data(data):
	super(data)
