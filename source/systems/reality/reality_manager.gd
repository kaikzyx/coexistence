# RealityManager autoload.
extends Node

signal reality_changed()
signal reality_mask_started()
signal reality_mask_finished()

var is_light_reality := false:
	set(value): is_light_reality = value; reality_changed.emit()
var light_viewport_texture: ViewportTexture = null
var dark_viewport_texture: ViewportTexture = null

var _can_change_reality := true

func _process(_delta: float) -> void:
	if light_viewport_texture:
		RenderingServer.global_shader_parameter_set(&"light_viewport_texture", light_viewport_texture)
	if dark_viewport_texture:
		RenderingServer.global_shader_parameter_set(&"dark_viewport_texture", dark_viewport_texture)

func _input(event: InputEvent) -> void:
	if _can_change_reality and event.is_action_pressed(&"change_reality"):
		is_light_reality = not is_light_reality

func reality_mask_start() -> void:
	reality_mask_started.emit()
	_can_change_reality = false

func reality_mask_finish() -> void:
	reality_mask_finished.emit()
	_can_change_reality = true
