extends Sprite2D

@export var on_texture: Texture2D
@export var off_texture: Texture2D
@export var on_time: float = 0.45
@export var off_time: float = 0.12

var _is_on := true
var _time_left := 0.0

func _ready() -> void:
	_is_on = true
	_time_left = on_time
	texture = on_texture

func _process(delta: float) -> void:
	_time_left -= delta
	if _time_left > 0.0:
		return

	_is_on = not _is_on
	texture = on_texture if _is_on else off_texture
	_time_left = on_time if _is_on else off_time
