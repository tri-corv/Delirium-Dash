extends CanvasLayer

@export var nivel_numero: String = "-- II --"
@export var nivel_nombre: String = "LABORATORIO"
@export_multiline var contexto: String = "Las respuestas llegan demasiado pronto.
El Dr. Evans encontro un recorte que parece cerrar
el caso. El paciente 509. Un asesino. Un culpable.
Una historia completa.
Las historias completas no suelen encontrarse en
hospitales abandonados."
@export_multiline var objetivo: String = "> Encuentra las pistas 4/4
> No dejes que las alucinaciones te derroten
> Escapa del laboratorio"
@export_file("*.tscn") var siguiente_escena: String = "res://scenes/level_2.tscn"

@onready var label_numero: Label = $Control/Level
@onready var label_nombre: Label = $Control/Title
@onready var label_contexto: Label = $Control/Lore
@onready var label_objetivo: Label = $Control/Goal
@onready var label_prompt: Label = $Control/Prompt

var _transition_started := false

func _ready() -> void:
	label_numero.text = nivel_numero
	label_nombre.text = nivel_nombre
	label_contexto.text = contexto
	label_objetivo.text = objetivo
	
	_parpadear_texto()

func _parpadear_texto() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(label_prompt, "modulate:a", 0.2, 0.8)
	tween.tween_property(label_prompt, "modulate:a", 1.0, 0.8)

func _input(_event: InputEvent) -> void:
	if _transition_started:
		return

	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		_ir_al_nivel()

func _ir_al_nivel() -> void:
	_transition_started = true
	var tween := create_tween()
	tween.tween_callback(func(): get_tree().change_scene_to_file(siguiente_escena))
