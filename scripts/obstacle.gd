extends Area2D

@export var sanity_damage: float = 25.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_sanity_damage"):
		body.take_sanity_damage(sanity_damage)
