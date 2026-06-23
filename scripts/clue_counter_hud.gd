extends CanvasLayer

@export var clue_group: StringName = &"level_2_clue"
@export var total_clues: int = 4
@export var final_door_path: NodePath

@onready var counter_label: Label = $Bar/CounterLabel

var _found_clues := 0
var _found_notes: Array[Area2D] = []
var _final_door: Node = null

func _ready() -> void:
	_final_door = get_node_or_null(final_door_path)

	for node in get_tree().get_nodes_in_group(clue_group):
		if node.has_signal("completed") and not node.is_connected("completed", _on_note_completed):
			node.connect("completed", _on_note_completed)

	_update_counter()

func _on_note_completed(note: Area2D) -> void:
	if note in _found_notes:
		return

	_found_notes.append(note)
	_found_clues = mini(_found_notes.size(), total_clues)
	_update_counter()

func _update_counter() -> void:
	if _found_clues >= total_clues:
		counter_label.text = "Puerta desbloqueada"
	else:
		counter_label.text = "Pista encontrada %d/%d" % [_found_clues, total_clues]

	if _final_door != null and _final_door.has_method("set_clue_progress"):
		_final_door.set_clue_progress(_found_clues, total_clues)
