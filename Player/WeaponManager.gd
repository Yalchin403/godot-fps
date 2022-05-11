extends Spatial


enum WEAPON_SLOTS {MACHETE, MACHINE_GUN, SHOTGUN, ROCKET_LAUNCHER, NEW_GUN}
var slots_unlocked = {
	WEAPON_SLOTS.MACHETE: true,
	WEAPON_SLOTS.MACHINE_GUN: true,
	WEAPON_SLOTS.SHOTGUN: true,
	WEAPON_SLOTS.ROCKET_LAUNCHER: true,
	WEAPON_SLOTS.NEW_GUN: false
}

onready var weapons = $Weapons.get_children()
var cur_slot = 0
var cur_weapon = null


func _ready():
	pass
	

func switch_to_next_weapon():
	cur_slot = (cur_slot + 1) % slots_unlocked.size()
#	if !cur_slot:
#		switch_to_next_weapon()
#
#	else:
	switch_to_weapon_slot(cur_slot) 
	
	
func switch_to_previous_weapon():
	cur_slot = posmod((cur_slot - 1), slots_unlocked.size())
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
