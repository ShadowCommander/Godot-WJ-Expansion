# my_item_template.gd
extends PanelContainer # Change this to your preferred control type.
class_name LazyListEntry

signal entry_button_down(index: int, data)
signal entry_button_up(index: int, data)
signal entry_pressed(index: int, data)
signal entry_toggled(index: int, data, toggled_on: bool)

# Store the original data and index for later use
var item_data
var item_index: int = -1

var internal_button: BaseButton

func _init() -> void:
	internal_button = TextureButton.new()
	internal_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	internal_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(internal_button)

func _ready():
	focus_mode = Control.FOCUS_ALL
	# EXAMPLE: Access data
	internal_button.button_down.connect(_on_button_down)
	internal_button.button_up.connect(_on_button_up)
	internal_button.pressed.connect(_on_pressed)
	internal_button.toggled.connect(_on_toggled)

#region Button signal relay

func _on_button_down():
	entry_button_down.emit(item_index, item_data)

func _on_button_up():
	entry_button_up.emit(item_index, item_data)

func _on_pressed():
	entry_pressed.emit(item_index, item_data)

func _on_toggled(toggled_on: bool):
	entry_toggled.emit(item_index, item_data, toggled_on)
	
#endregion

# This is called by LazyListBox to configure the item
func configure_item(index: int, data):
	item_index = index
	item_data = data

# This is called by LazyListBox to set the data
func set_data(data):
	item_data = data
