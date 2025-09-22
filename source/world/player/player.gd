class_name Player extends CharacterBody2D

@onready var _hitbox: Area2D = $Hitbox

const SPEED := 100.0
const JUMP_FORCE := 300.0

var _backup_position := Vector2.ZERO

func _ready() -> void:
	RealityManager.reality_changed.connect(_on_reality_changed)
	_on_reality_changed(RealityManager.is_light_reality)

func _physics_process(delta: float) -> void:
	var movement := Input.get_axis(&"move_left", &"move_right")
	velocity.x = lerp(velocity.x, movement * SPEED, 10.0 * delta)

	if movement != 0: $Sprite.flip_h = movement == -1

	if is_on_floor():
		if Input.is_action_just_pressed(&"jump"): velocity.y = -JUMP_FORCE
	else:
		velocity.y += ProjectSettings.get_setting(&"physics/2d/default_gravity") as float * delta

	move_and_slide()

func _on_reality_changed(_is_light: bool) -> void:
	# Retuns to the backup position in case it collides with the world when changing reality.
	# Otherwise it just saves a new backup position.
	if _hitbox.has_overlapping_bodies():
		global_position = _backup_position
	else:
		_backup_position = global_position

	RealityManager.update_collision_mask(self)
	RealityManager.update_collision_mask(_hitbox, true)
