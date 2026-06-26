extends Area2D

@export var closed_texture: Texture2D = preload("res://assets/sprites/door_open.png")
@export var open_texture: Texture2D = preload("res://assets/sprites/door_closed.png")
@export var closed_scale: Vector2 = Vector2.ONE
@export var open_scale: Vector2 = Vector2.ONE
@export var close_delay: float = 0.45
@export var next_scene: String = ""
@export var camera_lift: float = 0.0
@export var required_clues: int = 0

@onready var sprite: Sprite2D = $Sprite2D

var _is_finishing := false
var _found_clues := 0

func _ready() -> void:
	sprite.texture = open_texture
	sprite.scale = open_scale
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _is_finishing or not body.is_in_group("player"):
		return

	if not is_unlocked():
		return

	_finish_level(body)

func set_clue_progress(found: int, total: int) -> void:
	_found_clues = found
	required_clues = total

func is_unlocked() -> bool:
	return required_clues <= 0 or _found_clues >= required_clues

func _finish_level(player: Node2D) -> void:
	_is_finishing = true
	player.freeze()

	var camera := player.get_node_or_null("Camera2D") as Camera2D
	var player_tween := create_tween()
	player_tween.set_parallel(true)
	player_tween.tween_property(player, "modulate:a", 0.0, 0.35)
	player_tween.tween_property(player, "scale", player.scale * 0.75, 0.35)
	if camera != null:
		player_tween.tween_property(camera, "position:y", camera.position.y - camera_lift, 0.35)

	await player_tween.finished
	await get_tree().create_timer(close_delay).timeout

	await _close_door()
	player.queue_free()

	if not next_scene.is_empty():
		get_tree().change_scene_to_file(next_scene)

func _close_door() -> void:
	sprite.texture = closed_texture
	sprite.scale = closed_scale

	var close_tween := create_tween()
	close_tween.tween_property(sprite, "scale", closed_scale * Vector2(0.92, 1.08), 0.08)
	close_tween.tween_property(sprite, "scale", closed_scale, 0.14)
	await close_tween.finished
