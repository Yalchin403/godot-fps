extends Spatial


enum WEAPON_SLOTS {MACHETE, MACHINE_GUN, SHOTGUN, ROCKET_LAUNCHER, NEW_GUN}
var slots_unlocked = {
	WEAPON_SLOTS.MACHETE: true,
	WEAPON_SLOTS.MACHINE_GUN: false,
	WEAPON_SLOTS.SHOTGUN: false,
	WEAPON_SLOTS.ROCKET_LAUNCHER: false,
}


onready var anim_player = $AnimationPlayer
onready var weapons = $Weapons.get_children()
var cur_slot = 0
var cur_weapon = null
var fire_point : Spatial
var bodies_to_exclude : Array = []
onready var alert_area_hearing = $AlertAreaHearing
onready var alert_area_los = $AlertAreaLos
signal ammo_changed

func _ready():
	pass


func init(_fire_point: Spatial, _bodies_to_exclude):
	fire_point = _fire_point
	bodies_to_exclude = _bodies_to_exclude
	for weapon in weapons:
		
		if weapon.has_method("init"):
			weapon.init(fire_point, bodies_to_exclude)
	
	switch_to_weapon_slot(WEAPON_SLOTS.MACHETE)
	weapons[WEAPON_SLOTS.MACHINE_GUN].connect("fired", self, "alert_nearby_enemies")
	weapons[WEAPON_SLOTS.SHOTGUN].connect("fired", self, "alert_nearby_enemies")
	weapons[WEAPON_SLOTS.ROCKET_LAUNCHER].connect("fired", self, "alert_nearby_enemies")
	
	for weapon in weapons:
		weapon.connect("fired", self, "emit_ammo_changed_signal")

func attack(attack_input_just_pressed: bool, attack_input_pressed: bool):
	if cur_weapon.has_method("attack"):
		cur_weapon.attack(attack_input_just_pressed, attack_input_pressed)


func switch_to_next_weapon():
	cur_slot = (cur_slot + 1) % slots_unlocked.size()
	
	if !slots_unlocked[cur_slot]:
		switch_to_next_weapon()
	else:
		switch_to_weapon_slot(cur_slot)
	
	
func switch_to_previous_weapon():
	cur_slot = posmod((cur_slot - 1), slots_unlocked.size())
	if !slots_unlocked[cur_slot]:
		switch_to_previous_weapon()
	else:
		switch_to_weapon_slot(cur_slot)
#	cur_slot = (cur_slot - 1) % slots_unlocked.size()  # this will result negative numbers too, so use posmod
	
	switch_to_weapon_slot(cur_slot)

func switch_to_weapon_slot(slot_index):
	if slot_index < 0 or slot_index >= slots_unlocked.size():
		return
	
	if !slots_unlocked[slot_index]:
		return
		
	disable_all_weapons()
	
	cur_weapon = weapons[slot_index]
	
	if cur_weapon.has_method("set_active"):
		cur_weapon.set_active()
	
	else:
		cur_weapon.show()
	
	emit_ammo_changed_signal()
	
func disable_all_weapons():
	for weapon in weapons:
		if weapon.has_method("set_inactive"):
			weapon.set_inactive()
		
		else:
			weapon.hide()
			

func unlock_weapon_slot(slot_index):
	if slot_index < 0 or slot_index >= slots_unlocked.size():
		return
	
	else:
		slots_unlocked[slot_index] = true
#		print(slot_index, ' ', slots_unlocked)
		
		# for now make it false again just not to confuse our weapon switcher
		slots_unlocked[slot_index] = false  # remove this line in the future


# test animations of functions
func animate_weapon():
	for weapon in weapons:
		weapon.get_node("AnimationPlayer").play("attack")


func update_animation(velocity: Vector3, grounded: bool):
	"""
		first two if statements explanation:
			first we check if we are in idle animation basically if we are not moving
			in the second one we are checking if we are off the ground or our velocity is too slow to shake the weapons
	
	""" 
	if cur_weapon.has_method("is_idle") and !cur_weapon.is_idle():
		anim_player.play("idle", 0.05)  # 0.05 is for animation blend
		
	if !grounded or velocity.length() < 15.0:
		anim_player.play("idle", 0.05)		

	# otherwise we shake the guns
	anim_player.play("moving")
	

func alert_nearby_enemies():
	var nearby_enemies = alert_area_los.get_overlapping_bodies()
	for nearby_enemy in nearby_enemies:
		if nearby_enemy.has_method("alert"):
			nearby_enemy.alert()
			
	nearby_enemies = alert_area_hearing.get_overlapping_bodies()
	for nearby_enemy in nearby_enemies:
		if nearby_enemy.has_method("alert"):
			nearby_enemy.alert(false)
			

func get_pickup(pickup_type, ammo):
	match pickup_type:
		Pickup.PICKUP_TYPES.MACHINE_GUN:
			if slots_unlocked[WEAPON_SLOTS.MACHINE_GUN]:
				weapons[WEAPON_SLOTS.MACHINE_GUN].ammo += ammo
				
			if !slots_unlocked[WEAPON_SLOTS.MACHINE_GUN]:
				slots_unlocked[WEAPON_SLOTS.MACHINE_GUN] = true
				
				# switch to machine gun
				switch_to_weapon_slot(WEAPON_SLOTS.MACHINE_GUN)
				weapons[WEAPON_SLOTS.MACHINE_GUN].ammo += ammo
				

		Pickup.PICKUP_TYPES.MACHINE_GUN_AMMO:
			weapons[WEAPON_SLOTS.MACHINE_GUN].ammo += ammo

		Pickup.PICKUP_TYPES.SHOT_GUN:
			if slots_unlocked[WEAPON_SLOTS.SHOTGUN]:
				weapons[WEAPON_SLOTS.SHOTGUN].ammo += ammo
				
			if !slots_unlocked[WEAPON_SLOTS.SHOTGUN]:
				slots_unlocked[WEAPON_SLOTS.SHOTGUN] = true
				
				# switch to SHOT_GUN
				switch_to_weapon_slot(WEAPON_SLOTS.SHOTGUN)
				weapons[WEAPON_SLOTS.SHOTGUN].ammo += ammo
		
		Pickup.PICKUP_TYPES.SHOT_GUN_AMMO:
			weapons[WEAPON_SLOTS.SHOTGUN].ammo += ammo

		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER:
			if slots_unlocked[WEAPON_SLOTS.ROCKET_LAUNCHER]:
				weapons[WEAPON_SLOTS.ROCKET_LAUNCHER].ammo += ammo
				
			if !slots_unlocked[WEAPON_SLOTS.ROCKET_LAUNCHER]:
				slots_unlocked[WEAPON_SLOTS.ROCKET_LAUNCHER] = true
				
				# switch to ROCKET_LAUNCHER
				switch_to_weapon_slot(WEAPON_SLOTS.ROCKET_LAUNCHER)
				weapons[WEAPON_SLOTS.ROCKET_LAUNCHER].ammo += ammo

		
		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER_AMMO:
			weapons[WEAPON_SLOTS.ROCKET_LAUNCHER].ammo += ammo
	
	emit_ammo_changed_signal()

func emit_ammo_changed_signal():
	emit_signal("ammo_changed", cur_weapon)
