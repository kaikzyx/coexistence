extends Node

@onready var _sub_viewport: SubViewport = $SubViewport

const _MASK_TWEEN_DURATION := 0.5

var _mask_instances_count := 0

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	RealityManager.reality_changed.connect(_on_reality_changed)

	_on_viewport_size_changed()
	_on_reality_changed()

	# Share the mask texture with the reality system for shader effects.
	RealityManager.reality_mask_texture = _sub_viewport.get_texture()

func _create_sprite_mask() -> Sprite2D:
	var mask := Sprite2D.new()

	mask.global_position = _calculate_mask_position()
	mask.texture = preload("res://assets/circle_mask.png")
	mask.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mask.modulate = Color.WHITE if RealityManager.is_light_reality else Color.BLACK

	return mask

func _calculate_mask_position() -> Vector2:
	var half_viewport: Vector2 = get_viewport().size / 2

	# Default to viewport center if player doesn't exist.
	if not is_instance_valid(Global.player):
		return half_viewport

	var camera := get_viewport().get_camera_2d()
	
	# Use player's absolute position if no camera is available.
	if not is_instance_valid(camera):
		return Global.player.global_position

	# Calculate screen-relative position considering camera zoom and offset.
	return (Global.player.global_position - camera.global_position) * camera.zoom + half_viewport

func _calculate_mask_scale(mask: Sprite2D) -> Vector2:
	var position := mask.global_position

	# Calculate the maximum distance from mask to viewport corners.
	var distance: float = max(
		abs(position.distance_to(Vector2.ZERO)),
		abs(position.distance_to(_sub_viewport.size)),
		abs(position.distance_to(Vector2(_sub_viewport.size.x, 0.0))),
		abs(position.distance_to(Vector2(0.0, _sub_viewport.size.y))))

	# Scale mask diameter to cover twice the maximum distance.
	return Vector2.ONE * (distance * 2 / mask.texture.get_width())

func _replace_previous_mask() -> void:
	# Remove the previous mask instance if it exists.
	if _mask_instances_count > 0:
		_sub_viewport.get_child(0).queue_free()

	_mask_instances_count += 1

func _on_reality_changed() -> void:
	if not is_instance_valid(Global.player): return

	var mask := _create_sprite_mask()
	var target_scale := _calculate_mask_scale(mask)

	if _mask_instances_count == 0:
		# First mask - set scale immediately without animation.
		mask.scale = target_scale
		_replace_previous_mask()
	else:
		# Subsequent masks - animate from zero to target scale.
		mask.scale = Vector2.ZERO

		var tween := get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(mask, ^"scale", target_scale, _MASK_TWEEN_DURATION)
		tween.tween_callback(_replace_previous_mask)

	_sub_viewport.add_child(mask)

func _on_viewport_size_changed() -> void:
	_sub_viewport.size = get_viewport().size
