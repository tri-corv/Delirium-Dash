extends Area2D

signal completed(note: Area2D)

@export var note_texture: Texture2D
@export var prompt_text: String = "Presiona E para leer"

@onready var prompt: Label = $CanvasLayer/Prompt
@onready var overlay: Control = $CanvasLayer/Overlay
@onready var note_image: TextureRect = $CanvasLayer/Overlay/NoteImage

var _player: Node = null
var _note_open := false
var _completed := false

func _ready() -> void:
	prompt.text = prompt_text
	prompt.hide()
	overlay.hide()
	note_image.texture = note_texture
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	if _completed:
		return

	if _player != null and not _note_open and Input.is_action_just_pressed("interact"):
		_open_note()
	elif _note_open and Input.is_action_just_pressed("ui_accept"):
		_close_note()

func _on_body_entered(body: Node2D) -> void:
	if _completed or not body.is_in_group("player"):
		return

	_player = body
	if _player.has_method("pause_for_interaction"):
		_player.pause_for_interaction()
	prompt.show()

func _open_note() -> void:
	_note_open = true
	prompt.hide()
	overlay.show()

func _close_note() -> void:
	_note_open = false
	_completed = true
	overlay.hide()

	if is_instance_valid(_player) and _player.has_method("resume_from_interaction"):
		_player.resume_from_interaction()

	monitoring = false
	prompt.hide()
	completed.emit(self)
