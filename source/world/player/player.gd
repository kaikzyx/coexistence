class_name Player extends CharacterBody2D

static func get_sprite_frames(is_light: bool) -> SpriteFrames:
	if is_light: return preload("res://assets/player/light_player_animation.tres")
	else: return preload("res://assets/player/dark_player_animation.tres")

signal back_to_backup_position(from: Vector2, to: Vector2)
signal direction_changed()

const SPEED := 100.0
const JUMP_FORCE := 300.0

var backup_position := Vector2.ZERO
var direction := 1:
	set(value):
		direction = value;
		direction_changed.emit()
		animated_sprite.flip_h = value == -1

@onready var hitbox: Area2D = $Hitbox
@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite

func _ready() -> void:
	RealityManager.reality_changed.connect(_on_reality_changed); _on_reality_changed()

	Global.player = self
	state_machine.start()

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _get_movement_input() -> int:
	return Input.get_axis(&"move_left", &"move_right") as int

func _is_moving() -> bool:
	return _get_movement_input() != 0

func _is_falling() -> bool:
	return velocity.y > 0

func _can_jump() -> bool:
	return Input.is_action_just_pressed(&"jump")

func _movement_system(delta: float) -> void:
	var movement := _get_movement_input()
	velocity.x = lerp(velocity.x, movement * SPEED, 10.0 * delta)

	if movement != 0: direction = movement

	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting(&"physics/2d/default_gravity") as float * delta

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

func _on_jump_state_physics_processed(delta: float) -> void:
	_movement_system(delta)

	if is_on_floor(): state_machine.request_state(&"run" if _is_moving() else &"idle")
	if _is_falling(): state_machine.request_state(&"fall")

func _on_fall_state_entered() -> void:
	animated_sprite.play(&"fall")

func _on_fall_state_physics_processed(delta: float) -> void:
	_movement_system(delta)

	if is_on_floor(): state_machine.request_state(&"run" if _is_moving() else &"idle")

#endregion
