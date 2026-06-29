extends CanvasLayer # Pantalla de introduccion previa al nivel 2.

@export var nivel_numero: String = "-- II --" # Numero o marcador del nivel.
@export var nivel_nombre: String = "LABORATORIO" # Nombre del nivel.
@export_multiline var contexto: String = "Las respuestas llegan demasiado pronto.
El Dr. Evans encontro un recorte que parece cerrar
el caso. El paciente 509. Un asesino. Un culpable.
Una historia completa.
Las historias completas no suelen encontrarse en
hospitales abandonados." # Texto narrativo que aparece antes del nivel.
@export_multiline var objetivo: String = "> Encuentra las pistas 4/4
> No dejes que las alucinaciones te derroten
> Escapa del laboratorio" # Objetivos visibles para el jugador.
@export_file("*.tscn") var siguiente_escena: String = "res://scenes/level_2.tscn" # Escena que se abre al continuar.

@onready var label_numero: Label = $Control/Level # Label para el numero del nivel.
@onready var label_nombre: Label = $Control/Title # Label para el titulo.
@onready var label_contexto: Label = $Control/Lore # Label para la historia.
@onready var label_objetivo: Label = $Control/Goal # Label para los objetivos.
@onready var label_prompt: Label = $Control/Prompt # Label que invita a continuar.

var _transition_started := false # Evita cambios de escena repetidos.

# Configura los textos al cargar la escena.
func _ready() -> void:
	label_numero.text = nivel_numero # Escribe el numero del nivel.
	label_nombre.text = nivel_nombre # Escribe el nombre del nivel.
	label_contexto.text = contexto # Escribe el texto narrativo.
	label_objetivo.text = objetivo # Escribe los objetivos.

	_parpadear_texto() # Activa el parpadeo del prompt.

# Hace que el prompt aparezca y desaparezca suavemente.
func _parpadear_texto() -> void:
	var tween := create_tween() # Crea la animacion.
	tween.set_loops() # Hace que se repita siempre.
	tween.tween_property(label_prompt, "modulate:a", 0.2, 0.8) # Disminuye opacidad.
	tween.tween_property(label_prompt, "modulate:a", 1.0, 0.8) # Aumenta opacidad.

# Espera input para empezar el nivel.
func _input(_event: InputEvent) -> void:
	if _transition_started: # Si ya se presiono continuar.
		return # No procesa mas entradas.

	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"): # Espacio o aceptar.
		_ir_al_nivel() # Va al nivel configurado.

# Cambia a la escena siguiente.
func _ir_al_nivel() -> void:
	_transition_started = true # Marca la transicion como iniciada.
	var tween := create_tween() # Crea un tween para ejecutar el callback.
	tween.tween_callback(func(): get_tree().change_scene_to_file(siguiente_escena)) # Carga la siguiente escena.
