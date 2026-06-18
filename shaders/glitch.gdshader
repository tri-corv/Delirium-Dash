shader_type canvas_item;

uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float time_speed : hint_range(0.1, 10.0) = 5.0;
uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_nearest;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float t = TIME * time_speed;
	vec4 base_color = texture(screen_tex, uv);

	float slow_flicker = random(vec2(floor(t * 2.0), 1.0));
	float fast_flicker = random(vec2(floor(t * 13.0), 2.0));
	float pulse = mix(slow_flicker, fast_flicker, 0.45);
	float brightness = mix(-0.45, 0.35, pulse) * glitch_intensity;

	float vignette = distance(uv, vec2(0.5));
	float edge_darkness = smoothstep(0.25, 0.85, vignette) * glitch_intensity * 0.18;
	float uneven_light = random(floor(uv * 5.0) + floor(t * 4.0)) * 0.08 * glitch_intensity;

	COLOR = base_color;
	COLOR.rgb += brightness + uneven_light;
	COLOR.rgb -= edge_darkness;
}
