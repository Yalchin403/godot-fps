extends KinematicBody
onready var anim_player = $Graphics/AnimationPlayer
onready var character_mover = $CharacherMover
onready var health_manager = $HealthManager
onready var nav : Navigation = get_parent() # not in here, but in the world scene its parent will be navigation node
enum STATES {IDLE, CHASE, ATTACK, DEAD}
var cur_state = STATES.IDLE
var player = null
export var sight_angle = 45.0
export var turn_speed = 360.0
var path = []
export var attack_range = 2.0
export var attack_rate = 0.5
var attack_anim_speed_mod = 0.5
var attack_timer : Timer
var can_attack = true
signal attack


func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout", self, "finish_attack")
	attack_timer.one_shot = true
	add_child(attack_timer)
	
	health_manager.connect("gibbed", $Graphics, "hide")
	
	player = get_tree().get_nodes_in_group("player")[0]
	var bone_attachments = $Graphics/Armature/Skeleton.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is HitBox:
				child.connect("hurt", self, "hurt")  # we connect the hurt signal of hitbox to the hurt method below	
	health_manager.init()
	health_manager.connect("dead", self, "set_state_dead")  # whenever health manager says dead, set_state_dead function will be called
	character_mover.init(self)
	set_state_idle()


func face_dir(dir: Vector3, delta):
	var angle_diff = global_transform.basis.z.angle_to(dir)
	var turn_right = sign(global_transform.basis.x.dot(dir))
	if abs(angle_diff) < deg2rad(turn_speed) * delta:
		rotation.y = atan2(dir.x, dir.z)
	
	else:
		rotation.y += turn_speed * delta * turn_right


func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_state_idle()
			
		STATES.CHASE:
			process_state_chase(delta)
			
		STATES.ATTACK:
			process_state_attack(delta)
			
		STATES.DEAD:
			process_state_die()


func set_state_idle():
	cur_state = STATES.IDLE
	anim_player.play("idle_loop", 0.2)


func set_state_chase():
	cur_state = STATES.CHASE
	anim_player.play("walk_loop")


func set_state_attack():
	cur_state = STATES.ATTACK
	anim_player.play("attack")


func set_state_dead():
	cur_state = STATES.DEAD
	anim_player.play("die")	
	character_mover.freeze()
	$CollisionShape.disabled = true


func process_state_idle():
	if can_see_player():
		set_state_chase()


func process_state_chase(delta):
	if within_dis_of_player(attack_range) and has_los_player():
		set_state_attack()
		
	var player_pos = player.global_transform.origin
	var our_pos = global_transform.origin
	path = nav.get_simple_path(our_pos, player_pos)
	var goal_pos = player_pos
	if path.size() > 0:
		goal_pos = path[1]
	
	var dir = goal_pos - our_pos
	dir.y = 0
	character_mover.set_move_vec(dir)
	face_dir(dir, delta)


func process_state_attack(delta):
	character_mover.set_move_vec(Vector3.ZERO)
#	face_dir(global_transform.origin.direction_to(player.global_transform.origin), delta)
	if can_attack:
	
		if !within_dis_of_player(attack_range) or !can_see_player():
			set_state_chase()
		
		else:
			start_attack()


func process_state_die():
	pass


func hurt(damage: int, dir: Vector3):
	if cur_state == STATES.IDLE:
		set_state_chase()  # if the enemy gets shot in the idle state, it should start chasing the player

	health_manager.hurt(damage, dir)


func can_see_player():
	var dir_to_player = global_transform.origin.direction_to(player.global_transform.origin)
	var forwards = global_transform.basis.z
	return rad2deg(forwards.angle_to(dir_to_player)) < sight_angle and has_los_player()


func has_los_player():
	var our_pos = global_transform.origin + Vector3.UP
	var player_pos = player.global_transform.origin + Vector3.UP
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(our_pos, player_pos, [], 1)
	
	if result:
		return false
	
	return true


func alert(check_los=true):
	if cur_state != STATES.IDLE:
		return
	
	if check_los and !has_los_player():
		return
		
	set_state_chase()


func start_attack():
	can_attack = false
	anim_player.play("attack", -1, attack_anim_speed_mod)
	attack_timer.start()


func finish_attack():
	can_attack = true
	

func emit_attack_signal():
	emit_signal("attack")


func within_dis_of_player(dis: float):
	return global_transform.origin.distance_to(player.global_transform.origin) < attack_range
		
