extends Node3D

#Data
@export_group("Data")
@export var distance : int = 10000
var bodies_to_exclude : Array = []
var damage : float = 1

#Refrences
@export_group("Refrences")
@export var bullet_hit_effect : PackedScene

func set_damage(_damage : float) -> void:
	damage = _damage

func set_bodies_to_exclude(_bodies_to_exclude : Array) -> void:
	bodies_to_exclude = _bodies_to_exclude

func fire() -> void:
	var space_state = get_world_3d().direct_space_state
	var our_position = global_transform.origin
	var physics_ray_query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(our_position, our_position - global_transform.basis.z * distance, 1 + 2 + 4, bodies_to_exclude)
	physics_ray_query.collide_with_areas = true
	physics_ray_query.collide_with_bodies = true
	var result = space_state.intersect_ray(physics_ray_query)
	
	if result and result.collider.has_method("hurt"):
		result.collider.hurt(damage, result.normal)
	elif result:
		var bullet_hit = bullet_hit_effect.instantiate()
		get_tree().current_scene.add_child(bullet_hit)
		bullet_hit.global_transform.origin = result.position
		
		if result.normal.angle_to(Vector3.UP) < 0.00005:
			return
		if result.normal.angle_to(Vector3.DOWN) < 0.00005:
			bullet_hit.rotate(Vector3.RIGHT, PI)
			return
		
		var y = result.normal
		var x = y.cross(Vector3.UP)
		var z = x.cross(y)
		
		bullet_hit.global_transform.basis = Basis(x, y, z)
