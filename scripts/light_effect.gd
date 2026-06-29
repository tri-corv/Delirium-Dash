extends Area2D # Area que contiene una luz parpadeante.

@onready var luz: PointLight2D = $PointLight2D # Luz que cambia de intensidad.
@onready var timer: Timer = $Timer # Temporizador que controla cada parpadeo.

# Arranca el parpadeo de la luz.
func _ready() -> void:
	timer.timeout.connect(_parpadear) # Cada timeout cambia la energia de la luz.
	timer.start() # Inicia el temporizador.

# Cambia intensidad y duracion del siguiente parpadeo.
func _parpadear() -> void:
	luz.energy = randf_range(0.4, 1.3) # Define una intensidad aleatoria.
	timer.wait_time = randf_range(0.05, 0.25) # Define cuanto tarda el proximo cambio.
	timer.start() # Reinicia el temporizador.
