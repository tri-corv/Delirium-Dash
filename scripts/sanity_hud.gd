extends CanvasLayer

@onready var sanity_bar: ProgressBar = $SanityPanel/SanityBar
@onready var sanity_effect: ColorRect = $SanityEffect
@onready var game_over_screen: Control = $GameOverScreen
@onready var game_over_audio: AudioStreamPlayer2D = $GameOverScreen/AudioStreamPlayer2D

var _camera: Camera2D = null
var _camera_base_offset := Vector2.ZERO
var _camera_base_rotation := 0.0
var _camera_base_zoom := Vector2.ONE
var _stress := 0.0
var _pulse := 0.0
var _last_sanity := -1.0
var _player: Node = null

func _ready() -> void:
	game_over_screen.hide()
	game_over_audio.stop()
	game_over_audio.attenuation = 0.0
	game_over_audio.max_distance = 100000.0
	sanity_effect.color = Color(0.55, 0.0, 0.0, 0.0)
	sanity_bar.max_value = 100.0
	sanity_bar.value = 100.0

	_connect_to_player()

func _connect_to_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return

	if player == _player:
		return

	_player = player
	_camera = player.get_node_or_null("Camera2D")
	if _camera != null:
		_camera_base_offset = _camera.offset
		_camera_base_rotation = _camera.rotation
		_camera_base_zoom = _camera.zoom

	if player.has_signal("sanity_changed") and not player.is_connected("sanity_changed", _on_sanity_changed):
		player.connect("sanity_changed", _on_sanity_changed)
	if player.has_signal("sanity_depleted") and not player.is_connected("sanity_depleted", _on_sanity_depleted):
		player.connect("sanity_depleted", _on_sanity_depleted)

	var current_sanity = player.get("sanity")
	var maximum_sanity = player.get("max_sanity")
	if current_sanity != null and maximum_sanity != null:
		_on_sanity_changed(current_sanity, maximum_sanity)

func _process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = null
		_connect_to_player()

	_pulse = maxf(_pulse - delta, 0.0)
	_update_screen_effect(delta)

func _on_sanity_changed(current: float, maximum: float) -> void:
	sanity_bar.max_value = maximum
	sanity_bar.value = current

	if maximum <= 0.0:
		return

	var previous_sanity := _last_sanity
	_last_sanity = current
	_stress = clampf(1.0 - (current / maximum), 0.0, 1.0)

	if previous_sanity >= 0.0 and current < previous_sanity:
		_pulse = 1.25

func _on_sanity_depleted() -> void:
	game_over_screen.show()
	_play_game_over_audio()
	_pulse = 2.0

func _play_game_over_audio() -> void:
	if _camera != null and is_instance_valid(_camera):
		game_over_audio.global_position = _camera.global_position
	elif _player != null and is_instance_valid(_player):
		game_over_audio.global_position = _player.global_position

	if not game_over_audio.playing:
		game_over_audio.play()

func _update_screen_effect(_delta: float) -> void:
	var pulse_strength := clampf(_pulse, 0.0, 1.0)
	var red_alpha := clampf((_stress * 0.22) + (pulse_strength * 0.32), 0.0, 0.55)
	var darkness := clampf(_stress * 0.16, 0.0, 0.24)
	sanity_effect.color = Color(0.55 + darkness, 0.0, 0.0, red_alpha)

	if _camera == null or not is_instance_valid(_camera):
		_camera = null
		return

	var shake := (_stress * 3.0) + (pulse_strength * 7.0)
	if shake <= 0.05:
		_camera.offset = _camera_base_offset
		_camera.rotation = _camera_base_rotation
		_camera.zoom = _camera_base_zoom
		return

	var zoom_noise := randf_range(-0.012, 0.012) * (_stress + pulse_strength)
	_camera.offset = _camera_base_offset + Vector2(
		randf_range(-shake, shake),
		randf_range(-shake, shake)
	)
	_camera.rotation = _camera_base_rotation + randf_range(-0.012, 0.012) * (_stress + pulse_strength)
	_camera.zoom = _camera_base_zoom + Vector2(zoom_noise, -zoom_noise)

func _unhandled_input(event: InputEvent) -> void:
	if not game_over_screen.visible or not (event is InputEventKey):
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_R:
		_restart_game()
	elif key_event.keycode == KEY_ESCAPE:
		_quit_game()

func _restart_game() -> void:
	get_tree().reload_current_scene()

func _quit_game() -> void:
	get_tree().quit()
