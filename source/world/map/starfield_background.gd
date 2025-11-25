@tool extends Node2D

@onready var _base: ColorRect = $ShaderParallax/Base
@onready var _pixel_art_parallax: Parallax2D = $PixelArtParallax
@onready var _animated_sprite: AnimatedSprite2D = $PixelArtParallax/AnimatedSprite

enum Reality { LIGHT, DARK }
@export var _reality := Reality.LIGHT:
	set(value):
		_reality = value
		if is_instance_valid(_base):
			match value:
				Reality.LIGHT:
					_base.material.set_shader_parameter(&"background_color", _LIGHT_COLOR)
					_base.material.set_shader_parameter(&"stars_color", _DARK_COLOR)
					_pixel_art_parallax.autoscroll.y = -100 * _AUTO_SCROLL_FACTOR
					_animated_sprite.play(&"light")
				Reality.DARK:
					_base.material.set_shader_parameter(&"background_color", _DARK_COLOR)
					_base.material.set_shader_parameter(&"stars_color", _LIGHT_COLOR)
					_pixel_art_parallax.autoscroll.y = 0
					_animated_sprite.play(&"dark")

const _LIGHT_COLOR := Color(&"#ededed")
const _DARK_COLOR := Color(&"#111111")
const _AUTO_SCROLL_FACTOR := 0.1

func _ready() -> void:
	_reality = _reality

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_base) or Engine.is_editor_hint(): return

	var camera := get_viewport().get_camera_2d()

	if is_instance_valid(camera):
		var c = camera.global_position
		if _reality == Reality.LIGHT:
			c += Time.get_ticks_usec() * _AUTO_SCROLL_FACTOR * Vector2.DOWN * delta
		_base.material.set_shader_parameter(&"offset", c)
