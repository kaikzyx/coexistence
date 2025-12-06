extends Node

const _MASK_TWEEN_DURATION := 0.5

@onready var _reality_mask: SubViewport = $RealityMask
@onready var _background_mask: ColorRect = $RealityMask/BackgroundMask
@onready var _sprite_mask: Sprite2D = $RealityMask/SpriteMask

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed); _on_viewport_size_changed()
	RealityManager.reality_changed.connect(_on_reality_changed);

	# Setup mask.
	_update_mask()
	_sprite_mask.scale = _calculate_mask_scale()

func _calculate_mask_position() -> Vector2:
	var half_viewport: Vector2 = get_viewport().size / 2

	# Default to viewport center if player doesn't exist.
	if not is_instance_valid(Global.player):
		return half_viewport

	var camera := get_viewport().get_camera_2d()

	# Use player's absolute position if no camera is available.
	if not is_instance_valid(camera):
		return Global.player.sprite.global_position

	# Calculate screen-relative position considering camera zoom and offset.
	var distance := Global.player.sprite.global_position - (camera.global_position + camera.offset)
	return distance * camera.zoom + half_viewport

func _calculate_mask_scale() -> Vector2:
	var position := _sprite_mask.global_position

	# Calculate the maximum distance from mask to viewport corners.
	var distance: float = max(
		abs(position.distance_to(Vector2.ZERO)),
		abs(position.distance_to(_reality_mask.size)),
		abs(position.distance_to(Vector2(_reality_mask.size.x, 0.0))),
		abs(position.distance_to(Vector2(0.0, _reality_mask.size.y))))

	# Scale mask diameter to cover twice the maximum distance.
	return Vector2.ONE * (distance * 2 / _sprite_mask.texture.get_width())

func _update_mask() -> void:
	_sprite_mask.global_position = _calculate_mask_position()
	_sprite_mask.modulate = Color.WHITE if RealityManager.is_light_reality else Color.BLACK
	_background_mask.color = Color.BLACK if RealityManager.is_light_reality else Color.WHITE

func _on_reality_changed() -> void:
	RealityManager.reality_mask_start()

	_update_mask()
	_sprite_mask.scale = Vector2.ZERO

	var tween := get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(_sprite_mask, ^"scale", _calculate_mask_scale(), _MASK_TWEEN_DURATION)
	tween.tween_callback(RealityManager.reality_mask_finish)

func _on_viewport_size_changed() -> void:
	_reality_mask.size = get_viewport().size
