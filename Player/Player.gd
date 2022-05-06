extends KinematicBody


export var mouse_sens = 0.5
onready var camera = $Camera  # it will wait before loading camera
onready var character_mover = $CharacherMover
onready var health_manager = $HealthManager
onready var weapon_manager = $Camera/WeaponManager

var move_vec = Vector3()
var is_dead = false


func _ready():
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	character_mover.init(self)
	health_manager.init()
#	weapon_manager.init()
	health_manager.connect("dead", self, "kill")  # whenever we get dead signal, we kill
		
func _process(delta):   # update
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
	if is_dead:
#		get_tree().quit()
#		return
		character_mover.freeze()  # will make the frozen = true in character_mover
		# any of the above line should do the trick
		# you can freeze the player, by returning nothing, quiting game and freezing the character_mover
		

	elif Input.is_action_just_pressed("move_forward"): # make it is_action_pressed if you want to move constantly
		move_vec -= Vector3.FORWARD
	
	elif Input.is_action_just_pressed("move_backward"):
		move_vec -= Vector3.BACK
		
	elif Input.is_action_just_pressed("move_left"):
		move_vec -= Vector3.LEFT
		
	elif Input.is_action_just_pressed("move_right"):
		move_vec -= Vector3.RIGHT
	
	elif Input.is_action_just_pressed("jump"):
		character_mover.jump()
	
	
	# set character mover
	character_mover.set_move_vec(move_vec)
	
	move_vec = Vector3()
	# check if jump pressed
	if Input.is_action_just_pressed("jump"):
		character_mover.jump()

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y  -= mouse_sens * event.relative.x
		camera.rotation_degrees.x -= mouse_sens * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)


func hurt(damage, dir):
	health_manager.hurt(damage, dir)


func heal(amount):
	health_manager.heal(amount)

func kill():
	is_dead = true
	character_mover.freeze()
