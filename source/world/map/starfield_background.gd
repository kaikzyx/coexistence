@tool extends Node2D

const _SHADER_PERIOD := 100000.0
const _AUTO_SCROLL_FACTOR := 0.1

@export var _reality_type := RealityManager.Type.LIGHT:
	set(value):
		_reality_type = value

		if Engine.is_editor_hint() or not is_instance_valid(_base): return

		match value:
			RealityManager.Type.LIGHT:
				_base.material.set_shader_parameter(&"background_color", RealityManager.LIGHT_COLOR)
				_base.material.set_shader_parameter(&"stars_color", RealityManager.DARK_COLOR)
				_pixel_art_parallax.autoscroll.y = -100 * _AUTO_SCROLL_FACTOR
				_animated_sprite.play(&"light")
			RealityManager.Type.DARK:
				_base.material.set_shader_parameter(&"background_color", RealityManager.DARK_COLOR)
				_base.material.set_shader_parameter(&"stars_color", RealityManager.LIGHT_COLOR)
				_pixel_art_parallax.autoscroll.y = 0
				_animated_sprite.play(&"dark")

@onready var _base: ColorRect = $ShaderParallax/Base
@onready var _pixel_art_parallax: Parallax2D = $PixelArtParallax
@onready var _animated_sprite: AnimatedSprite2D = $PixelArtParallax/AnimatedSprite

func _ready() -> void:
	_reality_type = _reality_type
	

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or not is_instance_valid(_base): return

	var camera := get_viewport().get_camera_2d()

	if is_instance_valid(camera):
		var offset = camera.global_position

		if _reality_type == RealityManager.Type.LIGHT:
			offset += Time.get_ticks_usec() * _AUTO_SCROLL_FACTOR * Vector2.DOWN * delta

		offset = Vector2(fmod(offset.x, _SHADER_PERIOD), fmod(offset.y, _SHADER_PERIOD))
		_base.material.set_shader_parameter(&"offset", offset)
