@tool class_name DustParticleEffect extends GPUParticles2D

enum Direction { LEFT, RIGHT, UP, DOWN }

static func spawn() -> DustParticleEffect:
	return preload("res://source/world/effects/dust_particle_effect.tscn").instantiate()

const _INITIAL_VELOCITY := 50.0

@export var reality_type := RealityManager.Type.DARK:
	set(value):
		reality_type = value

		var particle_process_material: ParticleProcessMaterial = process_material

		match value:
			RealityManager.Type.LIGHT:
				particle_process_material.color = RealityManager.DARK_COLOR
			RealityManager.Type.DARK:
				particle_process_material.color = RealityManager.LIGHT_COLOR

@export var direction := Direction.UP:
	set(value):
		direction = value

		var particle_process_material: ParticleProcessMaterial = process_material

		match value:
			Direction.LEFT:
				particle_process_material.direction = Vector3(1, -0.5, 0)
				particle_process_material.initial_velocity_min = 0.0
				particle_process_material.initial_velocity_max = _INITIAL_VELOCITY
			Direction.RIGHT:
				particle_process_material.direction = Vector3(-1, -0.5, 0)
				particle_process_material.initial_velocity_min = 0.0
				particle_process_material.initial_velocity_max = _INITIAL_VELOCITY
			Direction.UP:
				particle_process_material.direction = Vector3(0, -1, 0)
				particle_process_material.initial_velocity_min = 0.0
				particle_process_material.initial_velocity_max = _INITIAL_VELOCITY
			Direction.DOWN:
				particle_process_material.direction = Vector3(1, 0, 0)
				particle_process_material.initial_velocity_min = -_INITIAL_VELOCITY
				particle_process_material.initial_velocity_max = _INITIAL_VELOCITY

func _ready() -> void:
	if Engine.is_editor_hint(): return

	reality_type = reality_type
	direction = direction
	one_shot = true
	emitting = true
	finished.connect(queue_free)
