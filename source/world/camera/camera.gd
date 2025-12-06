class_name Camera extends Camera2D

const _DELAY_DURATION := 0.5
const _MIN_DELAY_RADIUS := 64.0

var min_limit := Vector2.ZERO
var max_limit := Vector2.ZERO

var _can_follow_target := true
var _target := Vector2.ZERO:
	set(value):
		var half_view := get_viewport_rect().size / zoom / 2
		_target = value.clamp(min_limit + half_view, max_limit - half_view)

func _ready() -> void:
	Global.player_initialized.connect(_on_player_initialized)

	# Override and reset camera limit.
	min_limit = Vector2(limit_left, limit_top); max_limit = Vector2(limit_right, limit_bottom)
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
	global_position = to - (from - global_position)

	# Create a camera delay.
	_can_follow_target = false
	await RealityManager.reality_mask_finished
	_can_follow_target = true
