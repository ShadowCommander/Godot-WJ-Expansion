extends Control

@export var inventory_item_list_ : ItemList
@export var shop_item_list_ : ItemList
@export var total_gold_coins_in_inventory_label_ : Label
@export var organize_inventory_button_ : Button

var item_registry : ItemRegistry = ItemRegistry.new()
var inventory_manager : InventoryManager = null

const inventory_save_file : String = "user://inventory.cfg"

enum item_ids {
	WHEAT_SEEDS,
	CORN_SEEDS,
	TOMATO_SEEDS,
	WHEAT,
	CORN,
	TOMATO,
	FERTILIZER,
	WATERING_CAN,
	GOLD_COIN,
}

func _ready() -> void:
	# Create a list of item, name, description, and icons:
	var script : GDScript = get_script()
	var base_icon_path : String = "res://scenes/inventory_icons/items.atlas_textures/"
	var item_list : Array[Array] = [
			[
				item_ids.WHEAT_SEEDS, "Wheat Seeds",
				"Plant these to grow wheat. Takes 3 days to mature.",
				base_icon_path + "wheat_seeds.tres",
				5,
			],
			[
				item_ids.CORN_SEEDS,
				"Corn Seeds",
				"Plant these to grow corn. Takes 5 days to mature.",
				base_icon_path + "corn_seeds.tres",
				8,
			],
			[
				item_ids.TOMATO_SEEDS,
				"Tomato Seeds",
				"Plant these to grow tomatoes. Takes 4 days to mature.",
				base_icon_path + "tomato_seeds.tres",
				12,
			],
			[
				item_ids.WHEAT,
				"Wheat",
				"Fresh wheat ready for processing or selling.",
				base_icon_path + "wheat.tres",
				15,
			],
			[
				item_ids.CORN,
				"Corn",
				"Sweet corn perfect for cooking or selling.",
				base_icon_path + "corn.tres",
				25,
			],
			[
				item_ids.TOMATO,
				"Tomato",
				"Ripe red tomato, great for recipes.",
				base_icon_path + "tomato.tres",
				20,
			],
			[
				item_ids.FERTILIZER,
				"Fertilizer",
				"Speeds up crop growth.",
				base_icon_path + "fertilizer.tres",
				30,
			],
			[
				item_ids.WATERING_CAN,
				"Watering Can",
				"Essential tool for watering crops.",
				base_icon_path + "watering_can.tres",
				45,
			],
		]

	# Initialize the ItemRegistry, which is a small database that contains data about each item in your inventory.
	for item_data : Array in item_list:
		var item_id : int =  item_data[0]
		var item_name : String = item_data[1]
		var item_description : String = item_data[2]
		var icon_path : String = item_data[3]
		var icon_texture : Texture2D = load(icon_path)
		var item_price : int = item_data[4]
		item_registry.add_item(item_id, item_name, item_description, icon_texture)
		item_registry.set_item_metadata(item_id, "price", item_price)

	# Include gold coin as the currency
	item_registry.add_item(item_ids.GOLD_COIN, "Gold Coin", "Currency")
	item_registry.set_stack_capacity(item_ids.GOLD_COIN, 999999999)
	item_registry.set_stack_count_limit(item_ids.GOLD_COIN, 1)

	# Create an inventory with the item information just configured
	inventory_manager = InventoryManager.new(item_registry)

	# Load inventory data if any
	if FileAccess.file_exists(inventory_save_file):
		var config_file : ConfigFile = ConfigFile.new()
		var _load_success : int = config_file.load(inventory_save_file)
		var inventory_data : Dictionary = config_file.get_value("Inventory", "data")
		inventory_manager.set_data(inventory_data)
	else:
		# Add some gold coins to the inventory in order to buy/sell items.
		var _ignore_excess : ExcessItems = inventory_manager.add(item_ids.GOLD_COIN, 10000)

	# Refresh inventory
	__refresh_inventory_list()

	## Populate shop item menu
	for item_data : Array in item_list:
		var item_id : int = item_data[0]
		var item_name : String = item_data[1]
		var icon_path : String = item_data[3]
		var icon_texture : Texture2D = load(icon_path)
		var item_price : int = item_registry.get_item_metadata(item_id, "price")
		var index : int = shop_item_list_.add_item(item_name + " - " + str(item_price) + " gold coins" , icon_texture)
		shop_item_list_.set_item_metadata(index, item_id)

	# Connect signals
	var _success : int = shop_item_list_.item_activated.connect(__on_shop_item_list_item_activated)
	_success = inventory_item_list_.item_activated.connect(__on_inventory_item_list_item_activated)
	_success = inventory_manager.slot_modified.connect(__on_inventory_slot_modified)
	_success = organize_inventory_button_.pressed.connect(_on_organize_inventory_button_pressed)

func _on_organize_inventory_button_pressed() -> void:
	var item_order : PackedInt64Array = [
	]
	inventory_manager.organize(item_order)

func _notification(p_notification : int) -> void:
	if p_notification == Window.NOTIFICATION_WM_CLOSE_REQUEST:
		# Save the inventory:
		var config_file : ConfigFile = ConfigFile.new()
		config_file.set_value("Inventory", "data", inventory_manager.get_data())
		var _success : int = config_file.save(inventory_save_file)

func __on_inventory_slot_modified(_p_slot_number : int) -> void:
	__refresh_inventory_list()


func __on_inventory_item_list_item_activated(p_index : int) -> void:
	var item_id : int = inventory_item_list_.get_item_metadata(p_index)
	var item_price : int = item_registry.get_item_metadata(item_id, "price")
	var item_name : String = item_registry.get_name(item_id)
	var purchased_amount : int = 1
	var _ignore : ExcessItems = inventory_manager.remove(item_id, 1)
	_ignore = inventory_manager.add(item_ids.GOLD_COIN, item_price * purchased_amount)
	print("Sold 1 " + item_name + " for " + str(item_price * purchased_amount) + " gold coins")
	total_gold_coins_in_inventory_label_.set_text("Gold Coins: " + str(inventory_manager.get_item_total(item_ids.GOLD_COIN)))


func __on_shop_item_list_item_activated(p_index : int) -> void:
	var item_id : int = shop_item_list_.get_item_metadata(p_index)
	var item_price : int = item_registry.get_item_metadata(item_id, "price")
	var item_name : String = item_registry.get_name(item_id)
	var purchased_amount : int = 1
	if inventory_manager.has_item_amount(item_ids.GOLD_COIN, item_price):
		var _ignore : ExcessItems = inventory_manager.remove(item_ids.GOLD_COIN, item_price * purchased_amount)
		_ignore = inventory_manager.add(item_id, purchased_amount)
		print("Purchased 1 " + item_name + " for " + str(purchased_amount) + " gold coins")
	else:
		print("Not enough money to buy 1 " +  item_name)
	total_gold_coins_in_inventory_label_.set_text("Gold Coins: " + str(inventory_manager.get_item_total(item_ids.GOLD_COIN)))


func __refresh_inventory_list() -> void:
	var previously_selected_index : int = -1
	if inventory_item_list_.is_anything_selected():
		var selected_items : PackedInt32Array = inventory_item_list_.get_selected_items()
		previously_selected_index = selected_items[0]
	inventory_item_list_.clear()
	for slot_number : int in inventory_manager.slots():
		if inventory_manager.is_slot_empty(slot_number):
			continue
		var item_id : int = inventory_manager.get_slot_item_id(slot_number)
		if item_id == item_ids.GOLD_COIN:
			continue
		var item_amount : int = inventory_manager.get_slot_item_amount(slot_number)
		var item_name : String = item_registry.get_name(item_id)
		var item_texture : Texture2D = item_registry.get_icon(item_id)
		var index : int = inventory_item_list_.add_item(item_name + " - " + str(item_amount), item_texture)
		inventory_item_list_.set_item_metadata(index, item_id)
	if previously_selected_index != -1:
		inventory_item_list_.force_update_list_size()
		if previously_selected_index < inventory_item_list_.get_item_count():
			inventory_item_list_.select(previously_selected_index)
	total_gold_coins_in_inventory_label_.set_text("Gold Coins: " + str(inventory_manager.get_item_total(item_ids.GOLD_COIN)))


func _on_exit_pressed() -> void:
	get_parent().visible = false
