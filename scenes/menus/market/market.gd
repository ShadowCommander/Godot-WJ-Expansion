extends Control

@onready var lazy_list_box: LazyListBox = $CenterContainer/PanelContainer/VBoxContainer/TabContainer/LazyListBox
const ICON = preload("res://icon.svg")
func _ready() -> void:
	var data: Array[MarketLazyListEntry.MarketEntryData] = [
		MarketLazyListEntry.MarketEntryData.new(0, ICON, "Daxon seeds", 10),
		MarketLazyListEntry.MarketEntryData.new(0, ICON, "Barbec seeds", 10)
	]
	lazy_list_box.set_data(data)
	lazy_list_box.entry_pressed.connect(_on_entry_pressed)
	
	
func _on_entry_pressed(index: int, data: MarketLazyListEntry.MarketEntryData) -> void:
	print("Entry pressed: ", index, ", data: {%s, %s, %s}" % [data.id, data.display_name, data.price])
