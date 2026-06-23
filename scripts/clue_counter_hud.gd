extends CanvasLayer

const SCREAM_SOUND := preload("res://assets/sounds/scream_horror1.mp3")
const GHOST_BREATH_SOUND := preload("res://assets/sounds/ghostbreath.ogg")
const SHADOW_TEXTURE := preload("res://assets/Level 2/shadow.png")

@export var clue_group: StringName = &"level_2_clue"
@export var total_clues: int = 4
@export var final_door_path: NodePath

@onready var counter_label: Label = $Bar/CounterLabel

var _found_clues := 0
var _found_notes: Array[Area2D] = []
var _final_door: Node = null
var _shadow_overlay: ColorRect = null
var _shadow_image: TextureRect = null
var _audio_player: AudioStreamPlayer = null
var _effect_tween: Tween = null

func _ready() -> void:
	_final_door = get_node_or_null(final_door_path)
	_setup_found_effect()

	for node in get_tree().get_nodes_in_group(clue_group):
		if node.has_signal("completed") and not node.is_connected("completed", _on_note_completed):
			node.connect("completed", _on_note_completed)

	_update_counter()

func _on_note_completed(note: Area2D) -> void:
	if note in _found_notes:
		return

	_found_notes.append(note)
	_found_clues = mini(_found_notes.size(), total_clues)
	_update_counter()
	_play_found_effect()

func _update_counter() -> void:
	if _found_clues >= total_clues:
		counter_label.text = "Puerta desbloqueada"
	else:
		counter_label.text = "Pista encontrada %d/%d" % [_found_clues, total_clues]

	if _final_door != null and _final_door.has_method("set_clue_progress"):
		_final_door.set_clue_progress(_found_clues, total_clues)

func _setup_found_effect() -> void:
	_shadow_overlay = ColorRect.new()
	_shadow_overlay.name = "ShadowOverlay"
	_shadow_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shadow_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shadow_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	add_child(_shadow_overlay)
	move_child(_shadow_overlay, 0)

	_shadow_image = TextureRect.new()
	_shadow_image.name = "ShadowImage"
	_shadow_image.texture = SHADOW_TEXTURE
	_shadow_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_shadow_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_shadow_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shadow_image.modulate = Color(0.02, 0.02, 0.02, 0.0)
	_shadow_image.visible = false
	add_child(_shadow_image)
	move_child(_shadow_image, 1)

	_audio_player = AudioStreamPlayer.new()
	_audio_player.name = "ClueFoundAudio"
	_audio_player.volume_db = 2.0
	add_child(_audio_player)

func _play_found_effect() -> void:
	if _shadow_overlay != null:
		if _effect_tween != null:
			_effect_tween.kill()

		_shadow_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
		_position_shadow_image()
		_effect_tween = create_tween()
		_effect_tween.tween_property(_shadow_overlay, "color:a", 0.62, 0.12)
		_effect_tween.parallel().tween_property(_shadow_image, "modulate:a", 0.82, 0.18)
		_effect_tween.parallel().tween_property(_shadow_image, "scale", Vector2(1.08, 1.08), 0.45)
		_effect_tween.tween_interval(0.16)
		_effect_tween.tween_property(_shadow_overlay, "color:a", 0.0, 0.55)
		_effect_tween.parallel().tween_property(_shadow_image, "modulate:a", 0.0, 0.55)
		_effect_tween.tween_callback(Callable(_shadow_image, "hide"))

	if _audio_player != null:
		_audio_player.stream = SCREAM_SOUND if randi() % 2 == 0 else GHOST_BREATH_SOUND
		_audio_player.play()

func _position_shadow_image() -> void:
	if _shadow_image == null:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	var shadow_size := Vector2(260.0, 360.0)
	var margin := 36.0

	_shadow_image.size = shadow_size
	_shadow_image.scale = Vector2.ONE
	_shadow_image.pivot_offset = shadow_size * 0.5
	_shadow_image.position = Vector2(
		randf_range(margin, maxf(margin, viewport_size.x - shadow_size.x - margin)),
		randf_range(72.0, maxf(72.0, viewport_size.y - shadow_size.y - margin))
	)
	_shadow_image.modulate = Color(0.02, 0.02, 0.02, 0.0)
	_shadow_image.show()
