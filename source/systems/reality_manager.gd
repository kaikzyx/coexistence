# RealityManager autoload.
extends Node

signal reality_changed()

var is_light_reality := true:
	set(value): is_light_reality = value; reality_changed.emit()
var reality_mask_texture: ViewportTexture = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"change_reality"):
		is_light_reality = not is_light_reality

func update_collision_mask(collision_object: CollisionObject2D, is_inverse: bool = false) -> void:
	# Update the collision mask to the new reality.
	collision_object.set_collision_mask_value(2 if is_inverse else 1, is_light_reality)
	collision_object.set_collision_mask_value(1 if is_inverse else 2, not is_light_reality)
