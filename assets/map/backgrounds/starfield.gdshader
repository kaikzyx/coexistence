shader_type canvas_item;

uniform vec2 offset;
uniform vec4 background_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 stars_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float stars_scroll_scale = 0.01;
uniform float stars_amount = 0.002;

float rand(vec2 st) {
	return fract(sin(dot(st, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	float intensity = 0.0;
	vec2 norm_coord = FRAGCOORD.xy + floor(offset * stars_scroll_scale);

	// Small stars.
	if (rand(norm_coord / 20.0) > 1.0 - stars_amount) {
		float r = rand(norm_coord);
		intensity = max(intensity, r * (0.85 * sin(r * (TIME * 5.0 + 720.0)) + 0.95));
	}

	// Combine colors using mix function.
	COLOR = mix(background_color, stars_color, intensity);
}