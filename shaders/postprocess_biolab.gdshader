shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform float brightness : hint_range(0.8, 1.2, 0.001) = 1.0;
uniform float contrast : hint_range(0.8, 1.3, 0.001) = 1.08;
uniform float saturation : hint_range(0.8, 1.3, 0.001) = 1.06;
uniform vec3 color_tint : source_color = vec3(0.98, 1.00, 1.03);

uniform float vignette_strength : hint_range(0.0, 0.6, 0.001) = 0.17;
uniform float vignette_softness : hint_range(0.05, 0.8, 0.001) = 0.48;

uniform float grain_strength : hint_range(0.0, 0.08, 0.0001) = 0.016;
uniform float grain_speed : hint_range(0.0, 120.0, 0.01) = 48.0;

float _hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	vec4 screen_sample = texture(screen_texture, SCREEN_UV);
	vec3 color_value = screen_sample.rgb;

	float luminance = dot(color_value, vec3(0.2126, 0.7152, 0.0722));
	color_value = mix(vec3(luminance), color_value, saturation);
	color_value = (color_value - vec3(0.5)) * contrast + vec3(0.5);
	color_value *= brightness;
	color_value *= color_tint;

	vec2 centered_uv = SCREEN_UV * 2.0 - vec2(1.0);
	float distance_to_center = length(centered_uv);
	float vignette_amount = smoothstep(1.0 - vignette_softness, 1.0, distance_to_center);
	color_value *= 1.0 - (vignette_amount * vignette_strength);

	float grain_noise = (_hash(FRAGCOORD.xy + vec2(TIME * grain_speed, TIME * 0.37 * grain_speed)) - 0.5) * grain_strength;
	color_value += vec3(grain_noise);

	COLOR = vec4(clamp(color_value, vec3(0.0), vec3(1.0)), 1.0);
}
