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

	// Cortes horizontales aleatorios
	float block = floor(uv.y * 40.0);
	float line_glitch = random(vec2(block, floor(t * 8.0)));
	float shift = (line_glitch - 0.5) * glitch_intensity * 0.08;
	
	if (line_glitch > 0.85) {
		uv.x += shift * 3.0;
	}

	// Desplazamiento de canales RGB
	float offset = glitch_intensity * 0.006;
	vec4 col_r = texture(screen_tex, uv + vec2(offset, 0.0));
	vec4 col_g = texture(screen_tex, uv);
	vec4 col_b = texture(screen_tex, uv - vec2(offset, 0.0));

	COLOR = vec4(col_r.r, col_g.g, col_b.b, 1.0);

	// Ruido sutil
	float noise = random(uv + t) * glitch_intensity * 0.1;
	COLOR.rgb += noise;
}