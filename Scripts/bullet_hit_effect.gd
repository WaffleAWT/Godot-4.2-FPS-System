extends GPUParticles3D

func _ready() -> void:
	emitting = true
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
