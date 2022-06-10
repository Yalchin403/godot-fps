extends KinematicBody
onready var anim_player = $Graphics/AnimationPlayer
enum STATES {IDLE, CHASE, ATTACK, DEAD}
var cur_state = STATES.IDLE
onready var health_manager = $HealthManager
var player = null
export var sight_angle = 75.0


func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	var bone_attachments = $Graphics/Armature/Skeleton.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is HitBox:
				child.connect("hurt", self, "hurt")  # we connect the hurt signal of hitbox to the hurt method below	
	health_manager.init()
	health_manager.connect("dead", self, "set_state_dead")  # whenever health manager says dead, set_state_dead function will be called
	set_state_idle()


func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_state_idle()
			
		STATES.CHASE:
			process_state_chase()
			
		STATES.ATTACK:
			process_state_attack()
			
		STATES.DEAD:
			process_state_die()


func set_state_idle():
	cur_state = STATES.IDLE
	anim_player.play("idle_loop")
	

func set_state_chase():
	cur_state = STATES.CHASE
	anim_player.play("walk_loop")
	

func set_state_attack():
	cur_state = STATES.ATTACK
	anim_player.play("attack")
	

func set_state_dead():
	cur_state = STATES.DEAD
	anim_player.play("die")	


func process_state_idle():
	if can_see_player():
		set_state_chase()


func process_state_chase():
	pass


func process_state_attack():
	pass


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
