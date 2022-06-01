extends Area


export var damage = 40


func explode():
	$Particles2.emitting = true
	$Particles.emitting = true
	
	var query = PhysicsShapeQueryParameters.new()
	query.set_transform(global_transform)
	query.set_shape($CollisionShape)
	query.collision_mask = collision_mask
	var space_state = get_world().get_direct_space_state()
	var results = space_state.intersect_shape(query)
	
	for data in results:
		if data.collider.has_method("hurt"):
			data.collider.hurt(damage, global_transform.origin.direction_to(data.collider.global_transform.origin))
