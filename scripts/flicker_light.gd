extends Sprite2D # Sprite que alterna entre luz encendida y apagada.

@export var on_texture: Texture2D # Textura cuando la luz esta encendida.
@export var off_texture: Texture2D # Textura cuando la luz esta apagada.
@export var on_time: float = 0.45 # Tiempo que permanece encendida.
@export var off_time: float = 0.12 # Tiempo que permanece apagada.
@export var off_scale_multiplier := Vector2.ONE # Cambio de escala al apagarse.
@export var off_position_offset := Vector2.ZERO # Cambio de posicion al apagarse.

var _is_on := true # Estado actual de la luz.
var _time_left := 0.0 # Tiempo restante antes de alternar.
var _base_position := Vector2.ZERO # Posicion original del sprite.
var _base_scale := Vector2.ONE # Escala original del sprite.

# Guarda el estado base al iniciar.
func _ready() -> void:
	_base_position = position # Recuerda posicion inicial.
	_base_scale = scale # Recuerda escala inicial.
	_is_on = true # Empieza encendida.
	_time_left = on_time # Configura el primer tiempo encendido.
	_apply_light_state() # Aplica textura y transformacion inicial.

# Cuenta el tiempo y alterna el estado de la luz.
func _process(delta: float) -> void:
	_time_left -= delta # Descuenta el tiempo del frame.
	if _time_left > 0.0: # Si aun no toca cambiar.
		return # Mantiene el estado actual.

	_is_on = not _is_on # Invierte encendido/apagado.
	_apply_light_state() # Actualiza textura, posicion y escala.
	_time_left = on_time if _is_on else off_time # Define la duracion del nuevo estado.

# Aplica visualmente si la luz esta encendida o apagada.
func _apply_light_state() -> void:
	texture = on_texture if _is_on else off_texture # Cambia la textura segun el estado.

	if _is_on: # Si la luz esta encendida.
		position = _base_position # Vuelve a la posicion original.
		scale = _base_scale # Vuelve a la escala original.
	else: # Si la luz esta apagada.
		position = _base_position + off_position_offset # Aplica desplazamiento de apagado.
		scale = _base_scale * off_scale_multiplier # Aplica escala de apagado.
