extends Label


var ammo = 0
var health = 0


func update_ammo(ammount): # will connect this to WeaponManager ammo_changed signal
	ammo = ammount.ammo
	update_display()

func update_health(ammount):  # will connect this to HealthManager health_changed signal
	health = ammount
	update_display()
	
func update_display():
	var health_text = "Health:" + str(health) + "\n"
	var ammo_text = str(ammo)
	
	if ammo < 0:  # for machete kind of weapons we need to show ammo ammount as 0
		ammo_text = "inf"
	
	var heal_and_ammo_stat_message = health_text + ammo_text
	text = heal_and_ammo_stat_message

