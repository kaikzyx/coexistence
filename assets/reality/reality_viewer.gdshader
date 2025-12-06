shader_type canvas_item;

global uniform sampler2D light_viewport_texture : repeat_disable, filter_nearest;
global uniform sampler2D dark_viewport_texture : repeat_disable, filter_nearest;

void fragment() {
	vec4 light_viewport_color = texture(light_viewport_texture, UV);
	vec4 dark_viewport_color = texture(dark_viewport_texture, UV);

	// Grayscale mask: using red channel for intensity. (all channels are identical)
	float reality_mask_value = texture(TEXTURE, UV).r;

	COLOR = mix(dark_viewport_color, light_viewport_color, reality_mask_value);
}