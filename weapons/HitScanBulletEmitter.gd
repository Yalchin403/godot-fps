extends Spatial

# when we first load the game, we will load this asset up
var hit_effect = preload("res://effects/BulletHitEffect.tscn")
export var distance =  10000
var bodies_to_exclude = []
var damage = 1 #  will be overrided by weapons itself by set_damage function


func set_damage(_damage: int):
	damage = _damage
	

func set_bodie_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude
	

func fire():
	var space_state = get_world().get_direct_space_state()
	var our_pos = global_transform.origin
	var result = space_state.intersect_ray(our_pos, our_pos - global_transform.basis.z * distance,
	bodies_to_exclude, 1 + 2 + 4, true,
	true)  # 2 + 4 comes from the Player layers, those are the layers to interact
	
	if result and result.collider.has_method("hurt"):
		result.collider.hurt(damage, result.normal)
#		print("hit and it hurts")
		
	# if it doesn't have hurt method (for example a wall)
	elif result:
		var hit_effect_inst = hit_effect.instance()
		get_tree().get_root().add_child(hit_effect_inst)
		hit_effect_inst.global_transform.origin = result.position
		
		if result.normal.angle_to(Vector3.UP) < 0.00005:
			# if we hit something flat
			return # don't do anything
		
		if result.normal.angle_to(Vector3.DOWN) < 0.00005:
			# rotate the hit instance
			hit_effect_inst.rotate(Vector3.RIGHT, PI)
			return
			
		# cross product if it is neither of 2 cases above, to find the perpendicular direction
		var y = result.normal
		var x = y.cross(Vector3.UP)
		var z = x.cross(y) # x.cross(y) will retur cross product of the x and y which is going to be z
		
		hit_effect_inst.global_transform.basis = Basis(x, y, z)
