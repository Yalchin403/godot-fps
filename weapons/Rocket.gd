extends KinematicBody


var explosion = preload("res://weapons/Explosion.tscn")
export var speed = 5
export var impact_damage = 20  # will do extra damage to the thing we hit directly
var exploded = false


func _ready():
	hide()


func set_bodies_to_exclude(bodies_to_exclude: Array):
	for body in bodies_to_exclude:
		add_collision_exception_with(body)  # this won't let the rocket to collide with excluded bodies even if its in the same layer


func _physics_process(delta):
	show()
	var collision: KinematicCollision = move_and_collide(
		-global_transform.basis.z * speed * delta)
	
	if collision:
		var collider = collision.collider  # onject the we hit
		if collider.has_method("hurt"):
			collider.hurt(impact_damage, -global_transform.basis.z)
		explode()


func explode():
	if exploded:
		return
		
	exploded = true
	speed = 0
	$CollisionShape.disabled = true
	var explosion_inst = explosion.instance()
	get_tree().get_root().add_child(explosion_inst)
	explosion_inst.global_transform.origin = global_transform.origin
	
	explosion_inst.explode()
	
	$SmokeTrail.emitting = false
	$Graphics.hide()
	
	# here we first turn off the emitting and then we hide the graphics
	# if we dont turn of it wont look good
