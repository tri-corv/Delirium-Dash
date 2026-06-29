extends Area2D # La nota usa un area para detectar al jugador.

signal completed(note: Area2D) # Avisa cuando la nota ya fue leida y cerrada.

@export var note_texture: Texture2D # Imagen que se muestra al abrir la nota.
@export var prompt_text: String = "Presiona E para leer" # Texto que invita a interactuar.

@onready var prompt: Label = $CanvasLayer/Prompt # Texto visible cuando el jugador esta cerca.
@onready var overlay: Control = $CanvasLayer/Overlay # Panel que cubre la pantalla al leer.
@onready var note_image: TextureRect = $CanvasLayer/Overlay/NoteImage # Nodo que muestra la imagen de la nota.

var _player: Node = null # Guarda la referencia al jugador dentro del area.
var _note_open := false # Indica si la nota esta abierta.
var _completed := false # Indica si esta nota ya fue leida.

# Prepara la nota al iniciar.
func _ready() -> void:
	prompt.text = prompt_text # Coloca el texto configurable en el cartel.
	prompt.hide() # Oculta el cartel hasta que el jugador se acerque.
	overlay.hide() # Oculta la nota abierta al inicio.
	note_image.texture = note_texture # Asigna la imagen elegida desde el editor.
	body_entered.connect(_on_body_entered) # Escucha cuando el jugador entra en el area.

# Revisa inputs cada frame.
func _process(_delta: float) -> void:
	if _completed: # Si ya fue leida, no vuelve a funcionar.
		return # Sale sin procesar.

	if _player != null and not _note_open and Input.is_action_just_pressed("interact"): # Si el jugador esta cerca y pulsa E.
		_open_note() # Abre la nota.
	elif _note_open and Input.is_action_just_pressed("ui_accept"): # Si la nota esta abierta y acepta.
		_close_note() # Cierra la nota y la marca como completa.

# Detecta al jugador entrando en el area.
func _on_body_entered(body: Node2D) -> void:
	if _completed or not body.is_in_group("player"): # Ignora si ya se leyo o si no es el jugador.
		return # No hace nada.

	_player = body # Guarda el jugador actual.
	if _player.has_method("pause_for_interaction"): # Comprueba si puede pausarlo.
		_player.pause_for_interaction() # Detiene al jugador mientras decide leer.
	prompt.show() # Muestra el mensaje de interaccion.

# Muestra la imagen de la nota.
func _open_note() -> void:
	_note_open = true # Marca que la nota esta abierta.
	prompt.hide() # Oculta el mensaje de interaccion.
	overlay.show() # Muestra el panel con la nota.

# Cierra la nota y avisa que fue completada.
func _close_note() -> void:
	_note_open = false # Marca que la nota ya no esta abierta.
	_completed = true # Marca la nota como leida.
	overlay.hide() # Oculta el panel.

	if is_instance_valid(_player) and _player.has_method("resume_from_interaction"): # Si el jugador sigue existiendo.
		_player.resume_from_interaction() # Reactiva su movimiento.

	monitoring = false # Desactiva nuevas detecciones del area.
	prompt.hide() # Se asegura de que el cartel quede oculto.
	completed.emit(self) # Avisa a otros sistemas que esta pista fue encontrada.
