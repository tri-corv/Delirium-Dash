extends Area2D # El obstaculo detecta cuerpos que entran en su area.

@export var sanity_damage: float = 25.0 # Cantidad de cordura que quita al tocarlo.

# Se ejecuta cuando el obstaculo entra en la escena.
func _ready() -> void:
	body_entered.connect(_on_body_entered) # Conecta la senal de colision con la funcion local.
	for body in get_overlapping_bodies(): # Revisa cuerpos que ya esten dentro del area.
		_on_body_entered(body)

# Se ejecuta cuando un cuerpo entra en el area del obstaculo.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_sanity_damage"): # Solo afecta al jugador.
		body.take_sanity_damage(sanity_damage) # Le resta cordura al jugador.
