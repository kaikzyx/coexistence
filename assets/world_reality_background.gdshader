shader_type canvas_item;

uniform sampler2D reality_mask_texture : filter_nearest;
uniform vec3 light_background_color : source_color = vec3(1.0);
uniform vec3 dark_background_color : source_color = vec3(0.0);

void fragment() {
	// Grayscale mask: using red channel for intensity. (all channels are identical)
	float reality_mask_value = texture(reality_mask_texture, SCREEN_UV).r;

	// White areas use light color, black areas use dark color.
	COLOR.rgb = mix(dark_background_color, light_background_color, reality_mask_value);
}