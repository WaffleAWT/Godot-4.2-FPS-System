extends Node3D

#Data
enum WEAPON_SLOTS {WEAPON1, WEAPON2, WEAPON3}
var slots_unlocked : Dictionary = {
	WEAPON_SLOTS.WEAPON1 : true,
	WEAPON_SLOTS.WEAPON2 : true,
	WEAPON_SLOTS.WEAPON3 : true
}
var fire_point : Node3D
var bodies_to_exclude : Array = []

#Refrences
@export var animator : AnimationPlayer
@onready var weapons = $Weapons.get_children()
#@export var alert_area_hearing : Area3D
var current_slot : int = 0
var current_weapon = null

func _process(_delta : float) -> void:
	animate()

func init(_fire_point : Node3D, _bodies_to_exclude : Array) -> void:
	fire_point = _fire_point
	bodies_to_exclude = _bodies_to_exclude
	for weapon in weapons:
		if weapon.has_method("init"):
			weapon.init(_fire_point, _bodies_to_exclude)
	
	#weapons[WEAPON_SLOTS.WEAPON1].fired.connect(alert_nearby_enemies)
	#weapons[WEAPON_SLOTS.WEAPON2].fired.connect(alert_nearby_enemies)
	#weapons[WEAPON_SLOTS.WEAPON3].fired.connect(alert_nearby_enemies)
	
	switch_to_weapon_slot(WEAPON_SLOTS.WEAPON1)

func attack(attack_input_just_pressed : bool, attack_input_held : bool):
	if current_weapon.has_method("attack"):
		current_weapon.attack(attack_input_just_pressed, attack_input_held)

func switch_to_next_weapon() -> void:
	current_slot = (current_slot + 1) % slots_unlocked.size()
	if !slots_unlocked[current_slot]:
		switch_to_next_weapon()
	else:
		switch_to_weapon_slot(current_slot)

func switch_to_last_weapon() -> void:
	current_slot = posmod((current_slot - 1), slots_unlocked.size())
	if !slots_unlocked[current_slot]:
		switch_to_last_weapon()
	else:
		switch_to_weapon_slot(current_slot)

func switch_to_weapon_slot(slot_index : int) -> void:
	if slot_index < 0 or slot_index >= slots_unlocked.size():
		return
	if !slots_unlocked[current_slot]:
		return
	disable_all_weapons()
	current_weapon = weapons[slot_index]
	if current_weapon.has_method("set_active"):
		current_weapon.set_active()
	else:
		current_weapon.show()

func disable_all_weapons() -> void:
	for weapon in weapons:
		if weapon.has_method("set_inactive"):
			weapon.set_inactive()
		else:
			weapon.hide()

func animate():
	if owner.velocity != Vector3.ZERO and owner.is_on_floor():
		animator.play("move")
	else:
		animator.play("idle")

#func alert_nearby_enemies() -> void:
	#var nearby_enemies = alert_area_hearing.get_overlapping_bodies()
	#for nearby_enemy in nearby_enemies:
		#if nearby_enemy.has_method("alert"):
			#nearby_enemy.alert()
	#nearby_enemies = alert_area_hearing.get_overlapping_bodies()
	#for nearby_enemy in nearby_enemies:
		#if nearby_enemy.has_method("alert"):
			#nearby_enemy.alert(false)
