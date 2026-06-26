extends Area2D

@export var sanity_damage: float = 25.0 # Daño producido al colisionar con el obstáculo.

func _ready() -> void:
	body_entered.connect(_on_body_entered) # Conecta al jugador que puede colisionar

func _on_body_entered(body: Node2D) -> void:
	# Si el jugador tiene el método take_sanity y colisiona con un ostáculo, quita cordura
	if body.is_in_group("player") and body.has_method("take_sanity_damage"):
		body.take_sanity_damage(sanity_damage)
