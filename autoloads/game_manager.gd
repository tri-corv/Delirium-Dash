# autoloads/game_manager.gd
extends Node

signal crisis_happened
signal frasco_collected(total: int)

var crisis_count: int = 0
var frascos_collected: int = 0
var current_pabellon: int = 0
var narrative_unlocked: Array[String] = []

func reset_run() -> void:
	crisis_count = 0
	frascos_collected = 0
	current_pabellon = 0
	narrative_unlocked.clear()

func register_crisis() -> void:
	crisis_count += 1
	emit_signal("crisis_happened")

func collect_frasco(id: String) -> void:
	frascos_collected += 1
	if id not in narrative_unlocked:
		narrative_unlocked.append(id)
	emit_signal("frasco_collected", frascos_collected)

func reset_level() -> void:
	# No resetea crisis ni frascos, solo el estado del nivel
	get_tree().reload_current_scene()

func go_to_pabellon(index: int) -> void:
	current_pabellon = index
	# Siempre va a la intro primero
	get_tree().change_scene_to_file("res://scenes/intro_1.tscn")
	var scenes = [
		"res://scenes/levels/pabellon_admision.tscn",
		"res://scenes/levels/pabellon_hidroterapia.tscn",
		"res://scenes/levels/sotano_archivo.tscn",
	]
	get_tree().change_scene_to_file(scenes[index])
