extends CanvasLayer # El menu se dibuja encima de la pantalla.

@onready var control: Control = $Control # Contenedor principal del menu.
@onready var label_presiona: Label = $Control/Press # Texto que parpadea para empezar.
@onready var glitch_overlay: ColorRect = $Control/GlitchOverlay # Capa que usa el shader de glitch.

var flicker_material: ShaderMaterial # Material del overlay para modificar el shader.

# Configura la entrada del menu.
func _ready() -> void:
	control.modulate.a = 0.0 # Empieza invisible para hacer fade in.
	flicker_material = glitch_overlay.material as ShaderMaterial # Guarda el material del shader.
	var tween = create_tween() # Crea una animacion.
	tween.tween_property(control, "modulate:a", 1.0, 1.0) # Hace aparecer el menu en un segundo.

	_parpadear_texto() # Inicia el parpadeo del texto.
	_parpadeo_aleatorio() # Inicia el glitch aleatorio del fondo.

# Hace parpadear el texto de inicio para llamar la atencion.
func _parpadear_texto() -> void:
	var tween = create_tween() # Crea una animacion.
	tween.set_loops() # Repite la animacion indefinidamente.
	tween.tween_property(label_presiona, "modulate:a", 0.2, 0.8).set_trans(Tween.TRANS_SINE) # Baja la opacidad suavemente.
	tween.tween_property(label_presiona, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE) # Sube la opacidad suavemente.

# Lanza cambios de glitch en intervalos aleatorios.
func _parpadeo_aleatorio() -> void:
	while true: # Mantiene el efecto activo mientras exista el menu.
		var espera = randf_range(0.3, 1.6) # Elige cuanto esperar antes del siguiente parpadeo.
		await get_tree().create_timer(espera).timeout # Espera ese tiempo.
		_disparar_parpadeo() # Ejecuta un pulso de glitch.

# Cambia la intensidad del shader para crear un parpadeo.
func _disparar_parpadeo() -> void:
	var tween = create_tween() # Crea una animacion.
	tween.tween_property(flicker_material, "shader_parameter/glitch_intensity", randf_range(0.25, 1.0), randf_range(0.04, 0.12)) # Sube rapido el glitch.
	tween.tween_property(flicker_material, "shader_parameter/glitch_intensity", randf_range(0.0, 0.35), randf_range(0.08, 0.22)) # Lo baja parcialmente.
	tween.tween_property(flicker_material, "shader_parameter/glitch_intensity", 0.0, randf_range(0.12, 0.35)) # Lo apaga.

# Escucha input del jugador en el menu.
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"): # Espacio o aceptar empiezan.
		_comenzar_juego() # Inicia la transicion al juego.

# Cambia del menu a la primera introduccion.
func _comenzar_juego() -> void:
	var tween = create_tween() # Crea una animacion.
	tween.tween_property(control, "modulate:a", 0.0, 0.8) # Hace fade out del menu.
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/intro_1.tscn")) # Cambia de escena al terminar.
