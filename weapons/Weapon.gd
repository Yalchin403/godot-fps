extends Spatial


onready var anim_player = $AnimationPlayer
onready var bullet_emitters_base : Spatial = $BulletEmitters
onready var bullet_emitters = bullet_emitters_base.get_children()
export var automatic = false  # that's gonna decide whether it should continuously shoot or not when we click and hold mouse left button
var fire_point : Spatial  # point from which bullets will come out of
var bodies_to_exclude : Array = []
# if we want to set it individual for each weapon we can set export var damage in HitScanBulletEmitter script
export var damage = 5
export var ammo = 30  # Ammunition to start
export var attack_rate = 0.2
var attack_timer : Timer
var can_attack = true
signal fired
signal out_of_ammo


func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout", self, "finish_attack")
	attack_timer.one_shot =  true
	add_child(attack_timer)


func init(_fire_point: Spatial, _bodies_to_exclude: Array):
	fire_point = _fire_point
	bodies_to_exclude = _bodies_to_exclude
	
	for bullet_emitter in bullet_emitters:
		bullet_emitter.set_damage(damage)
		bullet_emitter.set_bodies_to_exclude(bodies_to_exclude)


func attack(attack_input_just_pressed: bool, attack_input_pressed: bool):
	if !can_attack:
		return
		
	if automatic and !attack_input_pressed:
		return
		
	if !automatic and !attack_input_just_pressed:
		return
		
	if ammo == 0:
		if attack_input_just_pressed:
			return
			emit_signal("out_of_ammo")
	
	if ammo > 0:
		ammo -= 1
 
	var start_transform = bullet_emitters_base.global_transform
	bullet_emitters_base.global_transform = fire_point.global_transform
	
	for bullet_emitter in bullet_emitters:
		bullet_emitter.fire()
		
	bullet_emitters_base.global_transform = start_transform
	anim_player.stop()
	anim_player.play("attack")
	emit_signal("fired")
	can_attack = false
	attack_timer.start()  # will start the timer and when its wait time ended fire function will get executed
	
	 
func set_active():
	show()
	$Crosshair.show()


func set_inactive():
	anim_player.play("idle")
	hide()
	$Crosshair.hide()
	
	
func finish_attack():
	can_attack = true


func is_idle():
	return !anim_player.is_playing() or anim_player.current_animation == "idle"
