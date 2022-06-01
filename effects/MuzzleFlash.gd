extends Spatial

# creating muzzle flash effect for the gun
export var flash_time = 0.05
var timer : Timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = flash_time
	timer.connect("timeout", self, "end_flash")
	hide()

		
func flash():
	timer.start()
	# doesn't work as expected, it doesn't just rotate but also moves somehow
#	rotation.z = rand_range(0.0, 0.005*PI)
	show()


func end_flash():
	hide()
