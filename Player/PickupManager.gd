extends Area


signal got_pickup
var max_player_health = 0
var current_player_health = 0


func update_player_health(amnt):
	current_player_health = amnt


func _ready():
	connect("area_entered", self, "on_area_enter")
	

func on_area_enter(pickup: Pickup):  # this Pickup refers to Pickup class that we defined on Pickup.gd
	if pickup.pickup_type == Pickup.PICKUP_TYPES.HEALTH and current_player_health == max_player_health:
		return  # don't increase health if it's already max
	
	
	emit_signal("got_pickup", pickup.pickup_type, pickup.ammo)
	pickup.queue_free()
