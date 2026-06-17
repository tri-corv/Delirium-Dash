extends CanvasLayer

@onready var sanity_bar: ProgressBar = $SanityPanel/SanityBar
@onready var game_over_screen: Control = $GameOverScreen

func _ready() -> void:
	game_over_screen.hide()

	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return

	if player.has_signal("sanity_changed"):
		player.sanity_changed.connect(_on_sanity_changed)
	if player.has_signal("sanity_depleted"):
		player.sanity_depleted.connect(_on_sanity_depleted)

	var current_sanity = player.get("sanity")
	var maximum_sanity = player.get("max_sanity")
	if current_sanity != null and maximum_sanity != null:
		_on_sanity_changed(current_sanity, maximum_sanity)

func _on_sanity_changed(current: float, maximum: float) -> void:
	sanity_bar.max_value = maximum
	sanity_bar.value = current

func _on_sanity_depleted() -> void:
	game_over_screen.show()

func _unhandled_input(event: InputEvent) -> void:
	if not game_over_screen.visible or not (event is InputEventKey):
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_R:
		_restart_game()
	elif key_event.keycode == KEY_ESCAPE:
		_quit_game()

func _restart_game() -> void:
	get_tree().reload_current_scene()

func _quit_game() -> void:
	get_tree().quit()
