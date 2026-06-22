extends Sprite2D

@export var on_texture: Texture2D
@export var off_texture: Texture2D
@export var on_time: float = 0.45
@export var off_time: float = 0.12
@export var off_scale_multiplier := Vector2.ONE
@export var off_position_offset := Vector2.ZERO

var _is_on := true
var _time_left := 0.0
var _base_position := Vector2.ZERO
var _base_scale := Vector2.ONE

func _ready() -> void:
	_base_position = position
	_base_scale = scale
	_is_on = true
	_time_left = on_time
	_apply_light_state()

func _process(delta: float) -> void:
	_time_left -= delta
	if _time_left > 0.0:
		return

	_is_on = not _is_on
	_apply_light_state()
	_time_left = on_time if _is_on else off_time

func _apply_light_state() -> void:
	texture = on_texture if _is_on else off_texture

	if _is_on:
		position = _base_position
		scale = _base_scale
	else:
		position = _base_position + off_position_offset
		scale = _base_scale * off_scale_multiplier
