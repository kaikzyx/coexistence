# RealityManager autoload.
extends Node

signal reality_changed(is_light: bool)

var is_light_reality := true:
	set(value): is_light_reality = value; reality_changed.emit(value)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"change_reality"):
		is_light_reality = not is_light_reality
