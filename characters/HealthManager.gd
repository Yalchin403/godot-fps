extends Spatial


"""
Signal is a delegation mechanism built into Godot that allows one game object to
react to a change in another without them referencing one another.
"""
signal dead
signal hurt
signal healed
signal health_changed
signal gibbed
var blood_spray = preload("res://effects/BloodSpray.tscn")
var gibs = preload("res://effects/Gibs.tscn")
export var max_health = 100
var cur_health = 1
export var gib_at = -20


func ready():
	init()
	

func init():
	cur_health = max_health
	emit_signal("health_changed", cur_health)
	
func hurt(damage: int, dir: Vector3, damage_type="normal"):
	spawn_blood(dir)
	if cur_health <= 0:
		return  # don't do anything to dead person :D
	
	cur_health -= damage

	if cur_health <= gib_at:
		# TODO:
		#	make gibs spawner
		spawn_gibs()
		emit_signal("gibbed")
		
	if cur_health <=0:
		emit_signal("dead")
		print("dead")
	else:
		emit_signal("hurt")
	
	emit_signal("health_changed", cur_health)
	var format_string = "Hurt: damage: {damage}, current health: {cur_health}"

	# Using the 'format' method, replace the 'str' placeholder
	var actual_string = format_string.format({"damage": damage, "cur_health": cur_health})
	print(actual_string)

func heal(amount: int):
	if cur_health <= 0:
		return  # dead can't be cured
		
	cur_health += amount
	
	if cur_health > max_health:
		cur_health = max_health
		
	var format_string = "Heal: heal amount: {amount}, current health: {cur_health}"
	var actual_string = format_string.format({"amount": amount, "cur_health": cur_health})
	print(actual_string)
		
	emit_signal("health_changed", cur_health)
	emit_signal("healed")

func spawn_blood(dir):
	var blood_spray_inst = blood_spray.instance()
	get_tree().get_root().add_child(blood_spray_inst)
	blood_spray_inst.global_transform.origin = global_transform.origin
	
	if dir.angle_to(Vector3.UP) < 0.00005:
		# if we hit something flat
		return # don't do anything
	
	if dir.angle_to(Vector3.DOWN) < 0.00005:
		# rotate the hit instance
		blood_spray_inst.rotate(Vector3.RIGHT, PI)
		return
		
	# cross product if it is neither of 2 cases above, to find the perpendicular direction
	var y = dir
	var x = y.cross(Vector3.UP)
	var z = x.cross(y) # x.cross(y) will retur cross product of the x and y which is going to be z
	
	blood_spray_inst.global_transform.basis = Basis(x, y, z)


func spawn_gibs():
	var gib_inst = gibs.instance()
	get_tree().get_root().add_child(gib_inst)
	gib_inst.global_transform.origin = global_transform.origin
	
	gib_inst.enable_gibs()


func get_pickup(pickup_type, ammo):
	match pickup_type:
		Pickup.PICKUP_TYPES.HEALTH:
			heal(ammo)
