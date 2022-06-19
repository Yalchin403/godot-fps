extends Label


const MAX_LINES = 5
var pickups_info = []

	
func _ready():
	text = ""
	
	
func add_pickups_info(pickup_type, amount):
	
	
	match pickup_type:
		Pickup.PICKUP_TYPES.MACHINE_GUN:
			pickups_info.push_back("Pick Up Machine Gun")
			
		
		Pickup.PICKUP_TYPES.SHOT_GUN:
			pickups_info.push_back("Pick Up Shot Gun")
		
		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER:
			pickups_info.push_back("Pick Up Rocket Launcher")
		
		Pickup.PICKUP_TYPES.MACHINE_GUN_AMMO:
			pickups_info.push_back("Pick Up Machine Gun Ammo " + str(amount))
			
		Pickup.PICKUP_TYPES.SHOT_GUN_AMMO:
			pickups_info.push_back("Pick Up Shot Gun Ammo " + str(amount))
		
		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER_AMMO:
			pickups_info.push_back("Pick Up Rocket Launcher Ammo " + str(amount))
		
	while pickups_info.size() >= MAX_LINES:
		pickups_info.pop_front()
	
	update_display()
	$RemoveInfoTimer.start()
	
	

func update_display():
	text = ""
	for pickup_info in pickups_info:
		text = text + pickup_info + "\n"
	
	
func remove_pickups_info():
	if pickups_info.size() > 0:
		pickups_info.pop_front()
		update_display()
