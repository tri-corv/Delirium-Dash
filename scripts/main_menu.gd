extends CanvasLayer

@onready var control: Control = $Control
@onready var label_presiona: Label = $Control/Press
@onready var glitch_overlay: ColorRect = $Control/GlitchOverlay

var glitch_material: ShaderMaterial

func _ready() -> void:
	control.modulate.a = 0.0
	glitch_material = glitch_overlay.material as ShaderMaterial
	var tween = create_tween()
	tween.tween_property(control, "modulate:a", 1.0, 1.0)
	
	_parpadear_texto()
	_glitch_aleatorio()

func _parpadear_texto() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(label_presiona, "modulate:a", 0.2, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label_presiona, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)

func _glitch_aleatorio() -> void:
	# Glitch en intervalos aleatorios para que se sienta inestable
	while true:
		var espera = randf_range(1.5, 4.0)
		await get_tree().create_timer(espera).timeout
		_disparar_glitch()

func _disparar_glitch() -> void:
	var tween = create_tween()
	tween.tween_property(glitch_material, "shader_parameter/glitch_intensity", 1.0, 0.05)
	tween.tween_property(glitch_material, "shader_parameter/glitch_intensity", 0.0, 0.15)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		_comenzar_juego()

func _comenzar_juego() -> void:
	var tween = create_tween()
	tween.tween_property(control, "modulate:a", 0.0, 0.8)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/intro_1.tscn"))
