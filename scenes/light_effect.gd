extends Node2D

@onready var luz = $PointLight2D
@onready var timer = $Timer

func _ready():
	timer.timeout.connect(_parpadear)
	timer.start()

func _parpadear():
	luz.energy = randf_range(0.4, 1.3)
	timer.wait_time = randf_range(0.05, 0.25)
	timer.start()
