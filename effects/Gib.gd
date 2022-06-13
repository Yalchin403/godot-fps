extends KinematicBody


export var start_move_speed = 30
export var grav = 35.0
export var drag = 0.01
export var velo_retained_on_bound = 0.8
var velocity = Vector3.ZERO
var initialized = false


#func _ready():
#	init()


func init():
	initialized =true
	velocity = -global_transform.basis.y * start_move_speed


func _physics_process(delta):
	if !initialized:
		return
	velocity += -velocity * drag + Vector3.DOWN * grav * delta
	var collision = move_and_collide(velocity * delta)
	
	# reflection equation: r = d - 2 * (d . n) * n  (can be used to create granade)
	if collision:
		var traveling_direction = velocity
		var normal = collision.normal
		var reflection = traveling_direction - 2 * traveling_direction.dot(normal) * normal
		velocity = reflection * velo_retained_on_bound
		
