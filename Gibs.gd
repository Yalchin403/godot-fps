extends Spatial


func _ready():
#	hide()
	enable_gibs()
	

func enable_gibs():
	for child in get_children():
		if child.has_method("init"):
			child.init()
		
		if "emitting" in child:
			child.emitting = true
