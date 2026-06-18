extends CanvasLayer

@onready var control: Control = $Control
@onready var label_presiona: Label = $Control/Press
@onready var glitch_overlay: ColorRect = $Control/GlitchOverlay

var flicker_material: ShaderMaterial

func _ready() -> void:
	control.modulate.a = 0.0
	flicker_material = glitch_overlay.material as ShaderMaterial
	var tween = create_tween()
	tween.tween_property(control, "modulate:a", 1.0, 1.0)
	
	_parpadear_texto()
	_parpadeo_aleatorio()

func _parpadear_texto() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(label_presiona, "modulate:a", 0.2, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label_presiona, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)

func _parpadeo_aleatorio() -> void:
	# Luz irregular para que el menu se sienta inestable.
	while true:
		var espera = randf_range(0.3, 1.6)
		await get_tree().create_timer(espera).timeout
		_disparar_parpadeo()

func _disparar_parpadeo() -> void:
	var tween = create_tween()
	tween.tween_property(flicker_material, "shader_parameter/glitch_intensity", randf_range(0.25, 1.0), randf_range(0.04, 0.12))
	tween.tween_property(flicker_material, "shader_parameter/glitch_intensity", randf_range(0.0, 0.35), randf_range(0.08, 0.22))
	tween.tween_property(flicker_material, "shader_parameter/glitch_intensity", 0.0, randf_range(0.12, 0.35))

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		_comenzar_juego()

func _comenzar_juego() -> void:
	var tween = create_tween()
	tween.tween_property(control, "modulate:a", 0.0, 0.8)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/intro_1.tscn"))
