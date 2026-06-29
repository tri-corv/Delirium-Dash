extends CanvasLayer # Pantalla final de la demo.

@onready var control: Control = $Control # Contenedor principal de la pantalla final.
@onready var prompt: Label = $Control/Prompt # Texto que indica acciones disponibles.

var _transition_started := false # Evita volver al menu mas de una vez.

# Hace aparecer la pantalla final.
func _ready() -> void:
	control.modulate.a = 0.0 # Empieza invisible.
	var fade_in := create_tween() # Crea animacion de entrada.
	fade_in.tween_property(control, "modulate:a", 1.0, 0.8) # Hace fade in.

	_blink_prompt() # Inicia parpadeo del prompt.

# Hace parpadear el texto de opciones.
func _blink_prompt() -> void:
	var tween := create_tween() # Crea animacion.
	tween.set_loops() # Repite para siempre.
	tween.tween_property(prompt, "modulate:a", 0.25, 0.8) # Baja opacidad.
	tween.tween_property(prompt, "modulate:a", 1.0, 0.8) # Sube opacidad.

# Escucha las teclas de la pantalla final.
func _unhandled_input(event: InputEvent) -> void:
	if _transition_started or not (event is InputEventKey): # Solo acepta teclas si no hay transicion activa.
		return # Ignora el evento.

	var key_event := event as InputEventKey # Convierte el evento a tecla.
	if not key_event.pressed or key_event.echo: # Ignora tecla soltada o repeticion automatica.
		return # No hace nada.

	if key_event.keycode == KEY_R: # R vuelve al menu.
		_return_to_main_menu() # Inicia retorno.
	elif key_event.keycode == KEY_ESCAPE: # Escape cierra el juego.
		get_tree().quit() # Sale de la aplicacion.

# Vuelve al menu principal con fade out.
func _return_to_main_menu() -> void:
	_transition_started = true # Bloquea inputs repetidos.

	var fade_out := create_tween() # Crea animacion de salida.
	fade_out.tween_property(control, "modulate:a", 0.0, 0.45) # Oculta la pantalla.
	fade_out.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn")) # Carga el menu.
