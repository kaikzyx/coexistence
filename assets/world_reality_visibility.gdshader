shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

global uniform sampler2D reality_mask_texture : filter_nearest;
uniform bool show_on_light_reality = true;
uniform bool is_canvas_group = false;

void fragment() {
	// Grayscale mask: using red channel for intensity. (all channels are identical)
	float reality_mask_value = texture(reality_mask_texture, SCREEN_UV).r;

	COLOR.a *= mix(1.0 - reality_mask_value, reality_mask_value, float(show_on_light_reality));

	if (is_canvas_group) {
		vec4 screen_color = textureLod(screen_texture, SCREEN_UV, 0.0);
		if (screen_color.a > 0.0001) { screen_color.rgb /= screen_color.a; }
		COLOR *= screen_color;
	}
}
