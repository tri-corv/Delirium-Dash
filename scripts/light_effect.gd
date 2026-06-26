extends Area2D

@export var sanity_damage: float = 25.0

@onready var luz: PointLight2D = $PointLight2D
@onready var timer: Timer = $Timer

var _player_in_light: Node2D = null

func _ready() -> void:
	timer.timeout.connect(_parpadear)
	timer.start()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if _player_in_light == null or not is_instance_valid(_player_in_light):
		_player_in_light = null
		return

	_player_in_light.call("take_sanity_damage", sanity_damage * delta)

func _parpadear() -> void:
	luz.energy = randf_range(0.4, 1.3)
	timer.wait_time = randf_range(0.05, 0.25)
	timer.start()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_sanity_damage"):
		_player_in_light = body

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_light:
		_player_in_light = null
