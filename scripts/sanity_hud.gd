extends CanvasLayer # Interfaz de cordura y pantalla de game over.

const EFFECT_COLOR := Color(0.55, 0.0, 0.0, 0.0) # Color base del efecto de baja cordura.

@onready var sanity_bar: ProgressBar = $SanityPanel/SanityBar # Barra que muestra la cordura.
@onready var sanity_effect: ColorRect = $SanityEffect # Capa roja que aparece al perder cordura.
@onready var game_over_screen: Control = $GameOverScreen # Pantalla que aparece al perder.
@onready var game_over_audio: AudioStreamPlayer2D = $GameOverScreen/AudioStreamPlayer2D # Sonido del game over.

var regen_label: Label = null # Texto que muestra el contador de recuperacion.
var _player: Node = null # Jugador conectado al HUD.
var _camera: Camera2D = null # Camara del jugador para aplicar sacudida.
var _camera_base_offset := Vector2.ZERO # Offset original de la camara.
var _stress := 0.0 # Intensidad del efecto segun la cordura perdida.
var _pulse := 0.0 # Golpe visual breve cuando baja la cordura.
var _last_sanity := -1.0 # Ultima cordura recibida.

# Configura la interfaz al iniciar.
func _ready() -> void:
	game_over_screen.hide()
	game_over_audio.stop()
	game_over_audio.attenuation = 0.0
	game_over_audio.max_distance = 100000.0
	sanity_effect.color = EFFECT_COLOR
	_create_regen_label()
	_connect_to_player()

# Busca al jugador y conecta sus senales de cordura.
func _connect_to_player() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if _player == null:
		return

	_camera = _player.get_node_or_null("Camera2D")
	if _camera != null:
		_camera_base_offset = _camera.offset

	_player.connect("sanity_changed", _on_sanity_changed)
	_player.connect("sanity_depleted", _on_sanity_depleted)
	_player.connect("sanity_regen_timer_changed", _on_sanity_regen_timer_changed)
	_on_sanity_changed(_player.get("sanity"), _player.get("max_sanity"))

# Crea un texto debajo de la barra para mostrar el contador.
func _create_regen_label() -> void:
	regen_label = Label.new()
	regen_label.position = Vector2(0, 50)
	regen_label.size = Vector2(260, 22)
	regen_label.text = "Recuperacion en: 5s"
	regen_label.add_theme_font_size_override("font_size", 12)
	regen_label.add_theme_color_override("font_color", Color(0.8, 0.9, 0.9, 1.0))
	$SanityPanel.add_child(regen_label)

# Actualiza el pulso y el efecto visual.
func _process(delta: float) -> void:
	_pulse = maxf(_pulse - delta, 0.0)
	_update_screen_effect()

# Actualiza la barra cuando cambia la cordura.
func _on_sanity_changed(current: float, maximum: float) -> void:
	sanity_bar.max_value = maximum
	sanity_bar.value = current

	if maximum <= 0.0:
		return

	_stress = clampf(1.0 - (current / maximum), 0.0, 1.0)
	if _last_sanity >= 0.0 and current < _last_sanity:
		_pulse = 1.25

	_last_sanity = current

# Actualiza el contador visible de recuperacion.
func _on_sanity_regen_timer_changed(seconds_left: int) -> void:
	if regen_label != null:
		regen_label.text = "Recuperacion en: %ds" % seconds_left

# Muestra la pantalla de derrota.
func _on_sanity_depleted() -> void:
	game_over_screen.show()
	_pulse = 2.0

	if _camera != null:
		game_over_audio.global_position = _camera.global_position
	if not game_over_audio.playing:
		game_over_audio.play()

# Aplica el color rojo y una sacudida simple de camara.
func _update_screen_effect() -> void:
	var pulse_strength := clampf(_pulse, 0.0, 1.0)
	var red_alpha := clampf((_stress * 0.22) + (pulse_strength * 0.32), 0.0, 0.55)
	sanity_effect.color = Color(EFFECT_COLOR.r, EFFECT_COLOR.g, EFFECT_COLOR.b, red_alpha)

	if _camera == null:
		return

	var shake := (_stress * 3.0) + (pulse_strength * 7.0) # shake de camara
	if shake <= 0.05:
		_camera.offset = _camera_base_offset
	else:
		_camera.offset = _camera_base_offset + Vector2(randf_range(-shake, shake), randf_range(-shake, shake))

# Permite reiniciar o salir cuando el game over esta visible.
func _unhandled_input(event: InputEvent) -> void:
	if not game_over_screen.visible or not (event is InputEventKey):
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_R:
		get_tree().reload_current_scene() # o change_scene_to_file("res://scenes/main_menu.tscn")
	elif key_event.keycode == KEY_ESCAPE:
		get_tree().quit()
