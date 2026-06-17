extends Area2D

@export var sanity_damage: float = 25.0

@onready var luz = $PointLight2D
@onready var timer = $Timer

func _ready():
	timer.timeout.connect(_parpadear)
	timer.start()
	body_entered.connect(_on_body_entered)

func _parpadear():
	luz.energy = randf_range(0.4, 1.3)
	timer.wait_time = randf_range(0.05, 0.25)
	timer.start()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_sanity_damage"):
		body.take_sanity_damage(sanity_damage)
