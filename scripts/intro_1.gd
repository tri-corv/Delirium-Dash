extends CanvasLayer # Pantalla de introduccion previa al nivel 1.

@export var nivel_numero: String = "-- I --" # Numero o marcador del nivel.
@export var nivel_nombre: String = "PABELLON DE ADMISION" # Nombre del nivel.
@export_multiline var contexto: String = "Las puertas ya no distinguen el adentro del afuera.
El Dr. Evans desperto en el ala este sin recordar
como llego. Los pasillos se contraen. Las camas
vacias no lo estan." # Texto narrativo que aparece en pantalla.
@export_multiline var objetivo: String = "> Esquiva los obstaculos
> Encuentra la Note 1
> Escapa del pabellón
> Cuida tu cordura" # Objetivos que se muestran al jugador.
@export_file("*.tscn") var siguiente_escena: String = "res://scenes/level_1.tscn" # Escena que se carga al continuar.

@onready var label_numero: Label = $Control/Level # Label para el numero del nivel.
@onready var label_nombre: Label = $Control/Title # Label para el nombre del nivel.
@onready var label_contexto: Label = $Control/Lore # Label para el texto narrativo.
@onready var label_objetivo: Label = $Control/Goal # Label para los objetivos.
@onready var label_prompt: Label = $Control/Prompt # Label que indica que se puede continuar.

var _transition_started := false # Evita iniciar la transicion mas de una vez.

# Coloca los textos en pantalla al iniciar.
func _ready() -> void:
	label_numero.text = nivel_numero # Muestra el numero del nivel.
	label_nombre.text = nivel_nombre # Muestra el nombre del nivel.
	label_contexto.text = contexto # Muestra la historia.
	label_objetivo.text = objetivo # Muestra los objetivos.

	_parpadear_texto() # Inicia el parpadeo del prompt.

# Hace parpadear el texto para continuar.
func _parpadear_texto() -> void:
	var tween := create_tween() # Crea una animacion.
	tween.set_loops() # Repite la animacion indefinidamente.
	tween.tween_property(label_prompt, "modulate:a", 0.2, 0.8) # Baja la opacidad.
	tween.tween_property(label_prompt, "modulate:a", 1.0, 0.8) # Sube la opacidad.

# Escucha la tecla para avanzar al nivel.
func _input(_event: InputEvent) -> void:
	if _transition_started: # Si ya empezo la transicion.
		return # Ignora mas inputs.

	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"): # Espacio o aceptar continuan.
		_ir_al_nivel() # Cambia al nivel.

# Cambia a la escena configurada.
func _ir_al_nivel() -> void:
	_transition_started = true # Marca que ya esta cambiando.
	var tween := create_tween() # Crea un tween aunque solo se use como cola de callback.
	tween.tween_callback(func(): get_tree().change_scene_to_file(siguiente_escena)) # Carga la escena siguiente.
