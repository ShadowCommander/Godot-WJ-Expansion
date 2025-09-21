extends Component
class_name GathererComponent

var value: int = 0
var time: int = 0
var delay: int = 200

func _ready() -> void:
	entity.plant_matured.connect(on_plant_mature)

func on_plant_mature() -> void:
	time = Time.get_ticks_msec()

func update_time() -> void:
	time += delay
