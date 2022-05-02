extends KinematicBody


export var mouse_sens = 0.5
onready var camera = $Camera  # it will wait before loading camera
onready var character_mover = $CharacherMover


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	character_mover.init(self)
	
func _process(delta):   # update
	var move_vec = Vector3()
	
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

	elif Input.is_action_just_pressed("move_forward"):
		move_vec -= Vector3.FORWARD
	
	elif Input.is_action_just_pressed("move_backward"):
		move_vec -= Vector3.BACK
		
	elif Input.is_action_just_pressed("move_left"):
		move_vec -= Vector3.LEFT
		
	elif Input.is_action_just_pressed("move_right"):
		move_vec -= Vector3.RIGHT
	
	elif Input.is_action_just_pressed("jump"):
		move_vec += Vector3.UP
	
	
	# set character mover
	character_mover.set_move_vec(move_vec)
	
	# check if jump pressed
	if Input.is_action_just_pressed("jump"):
		character_mover.jump()

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y  -= mouse_sens * event.relative.x
		camera.rotation_degrees.x -= mouse_sens * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
