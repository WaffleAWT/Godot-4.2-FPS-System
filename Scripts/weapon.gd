extends MeshInstance3D

#Signals
signal fired
signal out_of_ammo

#Data
@export_group("Data")
@export var automatic : bool = false
@export var damage : float
@export var ammo : int
@export var attack_rate : float
var attack_timer : Timer
var can_attack : bool = true
var fire_point : Node3D
var bodies_to_exclude : Array = []

#Refrences
@export_group("Refrences")
@export var animator : AnimationPlayer
@export var bullet_emitters_base : Node3D
@onready var bullet_emitters = bullet_emitters_base.get_children()

func _ready() -> void:
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.timeout.connect(finish_attack)
	attack_timer.one_shot = true
	add_child(attack_timer)

func init(_fire_point : Node3D, _bodies_to_exclude : Array) -> void:
	fire_point = _fire_point
	bodies_to_exclude = _bodies_to_exclude
	for bullet_emitter in bullet_emitters:
		bullet_emitter.set_damage(damage)
		bullet_emitter.set_bodies_to_exclude(bodies_to_exclude)

func attack(attack_input_just_pressed : bool, attack_input_held : bool) -> void:
	if !can_attack:
		return
	if automatic and !attack_input_held:
		return
	elif !automatic and !attack_input_just_pressed:
		return
	
	if ammo == 0:
		if attack_input_just_pressed:
			out_of_ammo.emit()
		return
	
	if ammo > 0:
		ammo -= 1
	
	var start_tranform = bullet_emitters_base.global_transform
	bullet_emitters_base.global_transform = fire_point.global_transform
	for bullet_emitter in bullet_emitters:
		bullet_emitter.fire()
	bullet_emitters_base.global_transform = start_tranform
	animator.stop()
	animator.play("attack")
	fired.emit()
	can_attack = false
	attack_timer.start()

func finish_attack() -> void:
	can_attack = true

func set_active():
	show()
	#Show the weapon's crosshair

func set_inactive() -> void:
	hide()
	animator.play("idle")
	#Hide the weapon's crosshair
