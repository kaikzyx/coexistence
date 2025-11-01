shader_type canvas_item;

global uniform sampler2D reality_mask_texture : filter_nearest;
uniform bool show_on_light_reality = true;

void fragment() {
	// Grayscale mask: using red channel for intensity. (all channels are identical)
	float reality_mask_value = texture(reality_mask_texture, SCREEN_UV).r;

	COLOR.a *= mix(1.0 - reality_mask_value, reality_mask_value, float(show_on_light_reality));
}