shader_type canvas_item; // Indica que el shader se aplica a elementos 2D de interfaz o sprites.

uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0; // Intensidad general del efecto.
uniform float time_speed : hint_range(0.1, 10.0) = 5.0; // Velocidad con la que cambia el parpadeo.
uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_nearest; // Textura de la pantalla actual.

// Genera un numero pseudoaleatorio a partir de una coordenada.
float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453); // Devuelve un valor entre 0 y 1.
}

// Calcula el color final de cada pixel.
void fragment() {
	vec2 uv = SCREEN_UV; // Coordenadas del pixel en la pantalla.
	float t = TIME * time_speed; // Tiempo escalado para controlar la velocidad.
	vec4 base_color = texture(screen_tex, uv); // Color original de la pantalla.

	float slow_flicker = random(vec2(floor(t * 2.0), 1.0)); // Ruido lento para cambios grandes.
	float fast_flicker = random(vec2(floor(t * 13.0), 2.0)); // Ruido rapido para vibracion.
	float pulse = mix(slow_flicker, fast_flicker, 0.45); // Mezcla ambos ruidos.
	float brightness = mix(-0.45, 0.35, pulse) * glitch_intensity; // Calcula cambio de brillo.

	float vignette = distance(uv, vec2(0.5)); // Mide distancia al centro de la pantalla.
	float edge_darkness = smoothstep(0.25, 0.85, vignette) * glitch_intensity * 0.18; // Oscurece bordes.
	float uneven_light = random(floor(uv * 5.0) + floor(t * 4.0)) * 0.08 * glitch_intensity; // Agrega luz irregular.

	COLOR = base_color; // Empieza desde el color original.
	COLOR.rgb += brightness + uneven_light; // Aplica brillo y ruido.
	COLOR.rgb -= edge_darkness; // Resta oscuridad en los bordes.
}
