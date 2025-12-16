class_name Player extends CharacterBody2D

static func get_sprite_frames(is_light: bool) -> SpriteFrames:
	if is_light: return preload("res://assets/player/light_player_animation.tres")
	else: return preload("res://assets/player/dark_player_animation.tres")

signal back_to_backup_position(from: Vector2, to: Vector2)
signal direction_changed()

const SPEED := 125.0
const JUMP_FORCE := 300.0
const MAX_GRAVITY := 350.0

const _JUMP_APEX_THRESHOLD := 75.0
const _JUMP_APEX_SPEED_FACTOR := 1.5
const _JUMP_APEX_GRAVITY_FACTOR := 0.4
const _JUMP_BRAKE_FACTOR := 0.5
const _JUMP_FALL_GRAVITY_FACTOR := 1.75
const _COYOTE_TIME := 0.1
const _JUMP_BUFFER_TIME := 0.1
const _SPRITE_STRETCH_SCALE_MIN := Vector2(1.0, 1.0)
const _SPRITE_STRETCH_SCALE_MAX := Vector2(0.75, 1.25)
const _SPRITE_SQUASH_SCALE_MIN := Vector2(1.25, 0.75)
const _SPRITE_SQUASH_SCALE_MAX := Vector2(1.5, 0.5)

var backup_position := Vector2.ZERO
var direction := 1:
	set(value):
		direction = value;
		direction_changed.emit()
		animated_sprite.flip_h = value == -1

var _was_on_floor := false
var _coyote_clock := 0.0
var _jump_buffer_clock := 0.0

@onready var hitbox: Area2D = $Hitbox
@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite

func _ready() -> void:
	RealityManager.reality_changed.connect(_on_reality_changed); _on_reality_changed()

	Global.player = self
	state_machine.start()

func _process(delta: float) -> void:
	_coyote_clock -= delta; _jump_buffer_clock -= delta

func _physics_process(delta: float) -> void:
	var old_velocity_y := velocity.y

	move_and_slide()

	# It creates a stretch and squash effect on the player based on velocity.
	if not is_on_floor():
		# Stretch effect when the player is on air.
		animated_sprite.scale.x = remap(abs(velocity.y), 0.0, MAX_GRAVITY,
			_SPRITE_STRETCH_SCALE_MIN.x, _SPRITE_STRETCH_SCALE_MAX.x)
		animated_sprite.scale.y = remap(abs(velocity.y), 0.0, MAX_GRAVITY,
			_SPRITE_STRETCH_SCALE_MIN.y, _SPRITE_STRETCH_SCALE_MAX.y)

		_was_on_floor = false
	elif not _was_on_floor:
		# Squash effect occurs when the player has just collided with the ground.
		animated_sprite.scale.x = remap(abs(old_velocity_y), 0.0, MAX_GRAVITY,
			_SPRITE_SQUASH_SCALE_MIN.x, _SPRITE_SQUASH_SCALE_MAX.x)
		animated_sprite.scale.y = remap(abs(old_velocity_y), 0.0, MAX_GRAVITY,
			_SPRITE_SQUASH_SCALE_MIN.y, _SPRITE_SQUASH_SCALE_MAX.y)

		_was_on_floor = true
		_dust_particle_effect(DustParticleEffect.Direction.DOWN)

	# Casic reading for the scale to return to the base scale.
	animated_sprite.scale = animated_sprite.scale.lerp(Vector2.ONE, 1.0 - pow(0.001, delta))

func get_sprite_center() -> Vector2:
	return global_position + animated_sprite.offset

func _movement_system(delta: float) -> void:
	var speed := SPEED

	if is_on_floor():
		# Reset the coyote time.
		_coyote_clock = _COYOTE_TIME
	else:
		var gravity: float = ProjectSettings.get_setting(&"physics/2d/default_gravity")

		# When the player is at the peak of the jump.
		if abs(velocity.y) < _JUMP_APEX_THRESHOLD:
			speed *= _JUMP_APEX_SPEED_FACTOR
			gravity *= _JUMP_APEX_GRAVITY_FACTOR

		# It makes the player fall faster.
		if not Input.is_action_pressed(&"jump"):
			gravity *= _JUMP_FALL_GRAVITY_FACTOR

		# Set a minimum and maximum limit for the gravity.
		velocity.y = clamp(velocity.y + gravity * delta, -MAX_GRAVITY, MAX_GRAVITY)

	# Reset the jump buffer.
	if Input.is_action_just_pressed(&"jump"):
		_jump_buffer_clock = _JUMP_BUFFER_TIME

	var movement := _get_movement_input()
	if movement != 0: direction = movement
	velocity.x = lerp(velocity.x, movement * speed, 1.0 - pow(0.0001, delta))

func _dust_particle_effect(dust_direction: DustParticleEffect.Direction) -> void:
	var dust := DustParticleEffect.spawn()
	dust.global_position = global_position
	dust.direction = dust_direction
	dust.reality_type = RealityManager.Type.LIGHT if RealityManager.is_light_reality else RealityManager.Type.DARK
	get_viewport().add_child(dust)

func _get_movement_input() -> int:
	return Input.get_axis(&"move_left", &"move_right") as int

func _is_moving() -> bool:
	return _get_movement_input() != 0

func _is_falling() -> bool:
	return velocity.y > 0

func _can_jump() -> bool:
	return _coyote_clock > 0 and _jump_buffer_clock > 0

func _on_reality_changed() -> void:
	var query := PhysicsShapeQueryParameters2D.new()
	var collision: CollisionShape2D = $Hitbox/Collision

	query.transform = collision.global_transform
	query.shape = collision.shape
	query.collision_mask = hitbox.collision_mask

	var result := get_viewport().world_2d.direct_space_state.intersect_shape(query, 1)

	# Retuns to the backup position in case it collides with the world when changing reality.
	# Otherwise it just saves a new backup position.
	if result.is_empty():
		backup_position = global_position
	else:
		# It is important that the signal is emitted beforehand to avoid bugs.
		back_to_backup_position.emit(global_position, backup_position)
		global_position = backup_position
		velocity = Vector2.ZERO

	# Changes the player's appearance based on current reality.
	var current_animation := animated_sprite.animation
	var current_frame := animated_sprite.frame
	var current_progress := animated_sprite.frame_progress

	animated_sprite.sprite_frames = get_sprite_frames(RealityManager.is_light_reality)
	animated_sprite.play(current_animation)
	animated_sprite.set_frame_and_progress(current_frame, current_progress)

#region State Machine

func _on_state_machine_state_changed(_from: State, to: State) -> void:
	print(&"Player state changed to: " + to.get_state_name())

func _on_idle_state_entered() -> void:
	animated_sprite.play(&"idle")

func _on_idle_state_physics_processed(delta: float) -> void:
	_movement_system(delta)

	if _is_moving(): state_machine.request_state(&"run")
	if _is_falling(): state_machine.request_state(&"fall")
	if _can_jump(): state_machine.request_state(&"jump")

func _on_run_state_entered() -> void:
	animated_sprite.play(&"run")

func _on_run_state_physics_processed(delta: float) -> void:
	_movement_system(delta)

	if not _is_moving(): state_machine.request_state(&"idle")
	if _is_falling(): state_machine.request_state(&"fall")
	if _can_jump(): state_machine.request_state(&"jump")

func _on_jump_state_entered() -> void:
	animated_sprite.play(&"jump")
	velocity.y = -JUMP_FORCE

	# It slows down the player if they are no longer pressing the jump button.
	if not Input.is_action_pressed(&"jump"):
		velocity.y *= _JUMP_BRAKE_FACTOR

	# Spawn dust based on the player's current direction.
	if _is_moving():
		_dust_particle_effect(
			DustParticleEffect.Direction.RIGHT if direction == 1 else DustParticleEffect.Direction.LEFT)
	else:
		_dust_particle_effect(DustParticleEffect.Direction.UP)

func _on_jump_state_physics_processed(delta: float) -> void:
	_movement_system(delta)

	# It slows the player down when the jump button is released.
	if Input.is_action_just_released(&"jump"):
		velocity.y *= _JUMP_BRAKE_FACTOR

	if is_on_floor(): state_machine.request_state(&"run" if _is_moving() else &"idle")
	if _is_falling(): state_machine.request_state(&"fall")

func _on_fall_state_entered() -> void:
	animated_sprite.play(&"fall")

func _on_fall_state_physics_processed(delta: float) -> void:
	_movement_system(delta)

	if is_on_floor(): state_machine.request_state(&"run" if _is_moving() else &"idle")
	if _can_jump(): state_machine.request_state(&"jump")

#endregion
