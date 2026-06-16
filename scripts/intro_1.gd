extends CanvasLayer

@export var nivel_numero: String = "-- I --"
@export var nivel_nombre: String = "PABELLON DE ADMISION"
@export_multiline var contexto: String = "Las puertas ya no distinguen el adentro del afuera.
El Dr. Evans desperto en el ala este sin recordar
como llego. Los pasillos se contraen. Las camas
vacias no lo estan."
@export_multiline var objetivo: String = "> Esquiva los obstaculos
> Llega a la puerta del fondo
> Recolecta los Frascos de Memoria"
@export_file("*.tscn") var siguiente_escena: String = "res://scenes/level.tscn"

@onready var label_numero: Label = $Control/Level
@onready var label_nombre: Label = $Control/Title
@onready var label_contexto: Label = $Control/Lore
@onready var label_objetivo: Label = $Control/Goal

var _transition_started := false

func _ready() -> void:
	label_numero.text = nivel_numero
	label_nombre.text = nivel_nombre
	label_contexto.text = contexto
	label_objetivo.text = objetivo

func _input(_event: InputEvent) -> void:
	if _transition_started:
		return

	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		_ir_al_nivel()

func _ir_al_nivel() -> void:
	_transition_started = true
	var tween := create_tween()
	tween.tween_callback(func(): get_tree().change_scene_to_file(siguiente_escena))
