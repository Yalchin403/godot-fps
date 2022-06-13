extends Spatial


var rocket = preload("res://weapons/Rocket.tscn")
var damage = 1
var bodies_to_exclude : Array = []


func set_damage(_damage):
	damage = _damage


func set_bodies_to_exclude(_bodies_to_exclude):
	bodies_to_exclude = _bodies_to_exclude


func fire():
	var rocket_inst = rocket.instance()
	rocket_inst.set_bodies_to_exclude(bodies_to_exclude)
	get_tree().get_root().add_child(rocket_inst)
	rocket_inst.global_transform = global_transform
	rocket_inst.impact_damage = damage
