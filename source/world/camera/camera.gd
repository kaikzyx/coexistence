class_name Camera extends Camera2D

@onready var min_limit := Vector2(limit_left, limit_top)
@onready var max_limit := Vector2(limit_right, limit_bottom)

const _DELAY_DURATION := 0.5
const _MIN_DELAY_RADIUS := 64.0

var _target := Vector2.ZERO:
	set(value):
		var half_view := get_viewport_rect().size / zoom / 2
		_target = value.clamp(min_limit + half_view, max_limit - half_view)

var _can_follow_target := true

func _ready() -> void:
	Global.player_initialized.connect(_on_player_initialized)

	# Reset camera limit.
	limit_left = -10000000; limit_top = -10000000; limit_right = 10000000; limit_bottom = 10000000

func _physics_process(delta: float) -> void:
	if is_instance_valid(Global.player):
		_target = Global.player.global_position
		if _can_follow_target: global_position = global_position.lerp(_target, 10.0 * delta)

func _on_player_initialized() -> void:
	Global.player.back_to_backup_position.connect(_on_player_back_to_backup_position)
	_target = Global.player.global_position
	global_position = _target

func _on_player_back_to_backup_position(from: Vector2, to: Vector2) -> void:
	var from_difference := from - global_position
	var to_difference := to - global_position
	var length := (to_difference - from_difference).length() - _MIN_DELAY_RADIUS

	global_position = to - from_difference

	# Create a camera delay when the player is closest to the corner of the camera. 
	if length > 0.0:
		var max_length: float = (get_viewport_rect().size / zoom).length() - _MIN_DELAY_RADIUS * 2
		var duration_factor: float = length / max_length

		_can_follow_target = false
		await get_tree().create_timer(duration_factor * _DELAY_DURATION + 0.1).timeout
		_can_follow_target = true
