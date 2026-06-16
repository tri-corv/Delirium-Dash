extends Area2D

@export var closed_texture: Texture2D = preload("res://assets/sprites/door_closed.png")
@export var open_texture: Texture2D = preload("res://assets/sprites/puerta.jpg")
@export var next_scene: String = ""

@onready var sprite: Sprite2D = $Sprite2D

var _is_finishing := false

func _ready() -> void:
	sprite.texture = closed_texture
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _is_finishing or not body.is_in_group("player"):
		return

	_finish_level(body)

func _finish_level(player: Node2D) -> void:
	_is_finishing = true
	player.freeze()

	sprite.texture = open_texture
	sprite.scale = Vector2.ONE
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(player, "modulate:a", 0.0, 0.35)
	tween.tween_property(player, "scale", player.scale * 0.75, 0.35)
	tween.tween_property(sprite, "scale", Vector2(1.04, 1.0), 0.12)

	await tween.finished
	player.queue_free()

	var close_tween := create_tween()
	close_tween.tween_interval(0.12)
	close_tween.tween_callback(func(): sprite.texture = closed_texture)
	close_tween.tween_property(sprite, "scale", Vector2(0.92, 1.08), 0.08)
	close_tween.tween_property(sprite, "scale", Vector2.ONE, 0.14)
	await close_tween.finished

	if not next_scene.is_empty():
		get_tree().change_scene_to_file(next_scene)
