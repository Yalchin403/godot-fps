extends KinematicBody


export var mouse_sens = 0.5
onready var camera = $Camera  # it will wait before loading camera
onready var character_mover = $CharacherMover
onready var health_manager = $HealthManager
onready var weapon_manager = $Camera/WeaponManager

var move_vec = Vector3()
var is_dead = false
var hotkeys = {
	KEY_1: 0,
	KEY_2: 1,
	KEY_3: 2,
	KEY_4: 3,
	KEY_5: 4,
	KEY_6: 5,
	KEY_7: 6,
	KEY_8: 7,
	KEY_9: 8,
	KEY_0: 9,
}

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	character_mover.init(self)
	health_manager.init()
	weapon_manager.init($Camera/FirePoint, [self])  # player > weapon_manager.init() > weapon
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
		

	elif Input.is_action_pressed("move_forward"): # make it is_action_pressed if you want to move constantly (was originally is_action_just_pressed
		move_vec -= Vector3.FORWARD
	
	elif Input.is_action_pressed("move_backward"):
		move_vec -= Vector3.BACK
		
	elif Input.is_action_pressed("move_left"):
		move_vec -= Vector3.LEFT
		
	elif Input.is_action_pressed("move_right"):
		move_vec -= Vector3.RIGHT
	
	elif Input.is_action_just_pressed("jump"):
		character_mover.jump()
	
	weapon_manager.attack(Input.is_action_just_pressed("attack"), Input.is_action_pressed("attack"))
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
		
	if event is InputEventKey and event.pressed:
		if event.scancode in hotkeys:
			weapon_manager.switch_to_weapon_slot(hotkeys[event.scancode])
		
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_DOWN:
			weapon_manager.switch_to_next_weapon()
		
		if event.button_index == BUTTON_WHEEL_UP:
			weapon_manager.switch_to_previous_weapon()
				

func hurt(damage, dir):
	print("Hit")
	health_manager.hurt(damage, dir)


func heal(amount):
	health_manager.heal(amount)

func kill():
	is_dead = true
	character_mover.freeze()


func unlock_weapon_slot(extra_arg_0):
	weapon_manager.unlock_weapon_slot(extra_arg_0)

