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

export var max_health = 100
var cur_health = 1
export var gib_at = -20

func ready():
	init()
	

func init():
	cur_health = max_health
	emit_signal("health_changed", cur_health)
	
func hurt(damage: int, dir: Vector3, damage_type="normal"):
	if cur_health <= 0:
		return  # don't do anything to dead person :D
	
	cur_health -= damage

	if cur_health <= gib_at:
		# TODO:
		#	make gibs spawner
		print("Player gibbed")
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
