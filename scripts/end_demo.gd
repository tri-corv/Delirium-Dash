extends CanvasLayer

@onready var control: Control = $Control
@onready var prompt: Label = $Control/Prompt

var _transition_started := false

func _ready() -> void:
	control.modulate.a = 0.0
	var fade_in := create_tween()
	fade_in.tween_property(control, "modulate:a", 1.0, 0.8)

	_blink_prompt()

func _blink_prompt() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(prompt, "modulate:a", 0.25, 0.8)
	tween.tween_property(prompt, "modulate:a", 1.0, 0.8)

func _unhandled_input(event: InputEvent) -> void:
	if _transition_started or not (event is InputEventKey):
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_R:
		_return_to_main_menu()
	elif key_event.keycode == KEY_ESCAPE:
		get_tree().quit()

func _return_to_main_menu() -> void:
	_transition_started = true

	var fade_out := create_tween()
	fade_out.tween_property(control, "modulate:a", 0.0, 0.45)
	fade_out.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
