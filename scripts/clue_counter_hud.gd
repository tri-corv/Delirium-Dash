extends CanvasLayer # Interfaz que muestra cuantas pistas encontro el jugador.

const SCREAM_SOUND := preload("res://assets/sounds/scream_horror1.mp3") # Sonido posible al encontrar una pista.
const GHOST_BREATH_SOUND := preload("res://assets/sounds/ghostbreath.ogg") # Segundo sonido posible al encontrar una pista.
const SHADOW_TEXTURE := preload("res://assets/Level 2/shadow.png") # Imagen de sombra usada como susto visual.
const SHADOW_SIZE := Vector2(260.0, 360.0) # Tamaño de la sombra del susto.
const SHADOW_MARGIN := 36.0 # Margen minimo contra los bordes.

@export var clue_group: StringName = &"level_2_clue" # Grupo donde estan las pistas del nivel.
@export var total_clues: int = 4 # Cantidad total de pistas requeridas.
@export var final_door_path: NodePath # Ruta hacia la puerta final que se desbloquea.

@onready var counter_label: Label = $Bar/CounterLabel # Texto que muestra el progreso.

var _found_notes: Array[Area2D] = [] # Notas ya contadas para no repetir.
var _final_door: Node = null # Puerta que recibe el progreso de pistas.
var _shadow_overlay: ColorRect # Capa oscura del susto.
var _shadow_image: TextureRect # Imagen de sombra del susto.
var _audio_player: AudioStreamPlayer # Reproductor del sonido de pista.
var _effect_tween: Tween = null # Animacion actual del susto.

# Prepara contador, puerta, pistas y efecto visual.
func _ready() -> void:
	_final_door = get_node_or_null(final_door_path) # Busca la puerta configurada en la escena.
	_create_found_effect_nodes() # Crea los nodos del efecto de pista encontrada.
	_connect_clues() # Conecta todas las notas del grupo.
	_update_counter() # Muestra el estado inicial.

# Conecta las pistas para saber cuando fueron leidas.
func _connect_clues() -> void:
	for node in get_tree().get_nodes_in_group(clue_group): # Recorre las pistas del nivel.
		if node.has_signal("completed"): # Solo conecta nodos que avisan cuando se completan.
			node.connect("completed", _on_note_completed) # Escucha esa pista.

# Se ejecuta cuando una nota fue leida y cerrada.
func _on_note_completed(note: Area2D) -> void:
	if note in _found_notes: # Evita contar dos veces la misma nota.
		return

	_found_notes.append(note) # Guarda la nota como encontrada.
	_update_counter() # Actualiza texto y puerta.
	_play_found_effect() # Reproduce susto visual y sonoro.

# Devuelve cuantas pistas se encontraron, sin pasar el total.
func _found_count() -> int:
	return mini(_found_notes.size(), total_clues)

# Actualiza el texto del HUD y el estado de la puerta.
func _update_counter() -> void:
	var found := _found_count() # Cantidad actual de pistas.
	counter_label.text = "Puerta desbloqueada" if found >= total_clues else ("Pista encontrada %d/%d" % [found, total_clues])

	if _final_door != null and _final_door.has_method("set_clue_progress"): # Si hay puerta configurada.
		_final_door.set_clue_progress(found, total_clues) # Le envia el progreso.

# Crea por codigo los nodos usados para el susto al encontrar una pista.
func _create_found_effect_nodes() -> void:
	_shadow_overlay = ColorRect.new() # Capa negra transparente.
	_shadow_overlay.name = "ShadowOverlay"
	_shadow_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shadow_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shadow_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	add_child(_shadow_overlay)
	move_child(_shadow_overlay, 0)

	_shadow_image = TextureRect.new() # Imagen de sombra que aparece brevemente.
	_shadow_image.name = "ShadowImage"
	_shadow_image.texture = SHADOW_TEXTURE
	_shadow_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_shadow_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_shadow_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shadow_image.visible = false
	add_child(_shadow_image)
	move_child(_shadow_image, 1)

	_audio_player = AudioStreamPlayer.new() # Sonido que acompana el susto.
	_audio_player.name = "ClueFoundAudio"
	_audio_player.volume_db = 2.0
	add_child(_audio_player)

# Reproduce el efecto de pista encontrada.
func _play_found_effect() -> void:
	if _effect_tween != null: # Si habia un susto anterior animandose.
		_effect_tween.kill() # Lo corta para empezar uno nuevo.

	_position_shadow_image() # Coloca la sombra en un lugar aleatorio.
	_shadow_overlay.color = Color(0.0, 0.0, 0.0, 0.0) # Reinicia la capa oscura.
	_effect_tween = create_tween() # Crea la animacion.
	_effect_tween.tween_property(_shadow_overlay, "color:a", 0.62, 0.12)
	_effect_tween.parallel().tween_property(_shadow_image, "modulate:a", 0.82, 0.18)
	_effect_tween.parallel().tween_property(_shadow_image, "scale", Vector2(1.08, 1.08), 0.45)
	_effect_tween.tween_interval(0.16)
	_effect_tween.tween_property(_shadow_overlay, "color:a", 0.0, 0.55)
	_effect_tween.parallel().tween_property(_shadow_image, "modulate:a", 0.0, 0.55)
	_effect_tween.tween_callback(Callable(_shadow_image, "hide"))

	_audio_player.stream = SCREAM_SOUND if randi() % 2 == 0 else GHOST_BREATH_SOUND # Elige un sonido.
	_audio_player.play()

# Posiciona la sombra en un lugar aleatorio de la pantalla.
func _position_shadow_image() -> void:
	var viewport_size := get_viewport().get_visible_rect().size # Tamano visible de la pantalla.

	_shadow_image.size = SHADOW_SIZE
	_shadow_image.scale = Vector2.ONE
	_shadow_image.pivot_offset = SHADOW_SIZE * 0.5
	_shadow_image.position = Vector2(
		randf_range(SHADOW_MARGIN, maxf(SHADOW_MARGIN, viewport_size.x - SHADOW_SIZE.x - SHADOW_MARGIN)),
		randf_range(72.0, maxf(72.0, viewport_size.y - SHADOW_SIZE.y - SHADOW_MARGIN))
	)
	_shadow_image.modulate = Color(0.02, 0.02, 0.02, 0.0)
	_shadow_image.show()
