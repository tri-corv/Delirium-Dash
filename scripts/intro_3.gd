extends CanvasLayer

@export var nivel_numero: String = "-- III --"
@export var nivel_nombre: String = "SUBSUELO"
@export_multiline var contexto: String = "Algunas puertas fueron cerradas para siempre.
El Dr. Evans descendio al subsuelo siguiendo las
ultimas pistas. Los nombres borrados reaparecen.
Las historias alteradas comienzan a encajar.
El paciente 509 no era el monstruo de esta
historia.
Los verdaderos responsables nunca abandonaron
el hospital."
@export_multiline var objetivo: String = "> No dejes que la sombra te atrape
> Escapa del subsuelo
> Descubre la verdad"
@export_file("*.tscn") var siguiente_escena: String = ""

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
