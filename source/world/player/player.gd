class_name Player extends CharacterBody2D

static var light_texture: Texture2D = preload("res://assets/player/light_player.png")
static var dark_texture: Texture2D = preload("res://assets/player/dark_player.png")

signal back_to_backup_position(from: Vector2, to: Vector2)

const SPEED := 100.0
const JUMP_FORCE := 300.0

var backup_position := Vector2.ZERO

@onready var state_machine: StateMachine = $StateMachine
@onready var hitbox: Area2D = $Hitbox
@onready var sprite: Sprite2D = $Sprite

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

	if movement != 0: sprite.flip_h = movement == -1

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

	sprite.texture = light_texture if RealityManager.is_light_reality else dark_texture

#region State Machine

func _on_state_machine_state_changed(_from: State, to: State) -> void:
	print(&"Player state changed to: " + to.get_state_name())

func _on_idle_state_physics_processed(delta: float) -> void:
	_movement_system(delta)

	if _is_moving(): state_machine.request_state(&"walk")
	if _is_falling(): state_machine.request_state(&"fall")
	if _can_jump(): state_machine.request_state(&"jump")

func _on_walk_state_physics_processed(delta: float) -> void:
	_movement_system(delta)

	if not _is_moving(): state_machine.request_state(&"idle")
	if _is_falling(): state_machine.request_state(&"fall")
	if _can_jump(): state_machine.request_state(&"jump")

func _on_jump_state_entered() -> void:
	velocity.y = -JUMP_FORCE

func _on_jump_state_physics_processed(delta: float) -> void:
	_movement_system(delta)

	if is_on_floor(): state_machine.request_state(&"walk" if _is_moving() else &"idle")
	if _is_falling(): state_machine.request_state(&"fall")

func _on_fall_state_physics_processed(delta: float) -> void:
	_movement_system(delta)

	if is_on_floor(): state_machine.request_state(&"walk" if _is_moving() else &"idle")

#endregion
