extends CharacterBody2D

signal sanity_changed(current: float, maximum: float)
signal sanity_depleted

@export var gravity_mode: bool = false
@export var max_sanity: float = 100.0

const MOVE_SPEED: float = 280.0
const JUMP_FORCE: float = -700.0
const GRAVITY: float = 1200.0

var is_dead: bool = false
var is_paused: bool = false
var gravity_direction: int = 1
var sanity: float = max_sanity

func _ready() -> void:
	sanity = max_sanity
	sanity_changed.emit(sanity, max_sanity)

func _physics_process(delta: float) -> void:
	if is_dead or is_paused:
		return

	if not is_on_floor() and not is_on_ceiling():
		velocity.y += GRAVITY * gravity_direction * delta

	velocity.x = MOVE_SPEED

	if Input.is_action_just_pressed("jump"):
		if gravity_mode:
			_flip_gravity()
		else:
			_jump()

	move_and_slide()

func _jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_FORCE

func _flip_gravity() -> void:
	gravity_direction *= -1
	velocity.y = 0.0
	scale.y *= -1

func die() -> void:
	if is_dead:
		return
	is_dead = true
	await get_tree().create_timer(0.35).timeout
	GameManager.register_crisis()
	GameManager.reset_level()

func freeze() -> void:
	is_dead = true
	velocity = Vector2.ZERO

func pause_for_interaction() -> void:
	is_paused = true
	velocity = Vector2.ZERO

func resume_from_interaction() -> void:
	is_paused = false

func take_sanity_damage(amount: float) -> void:
	if is_dead:
		return

	sanity = maxf(sanity - amount, 0.0)
	sanity_changed.emit(sanity, max_sanity)

	if sanity <= 0.0:
		_trigger_game_over()

func _trigger_game_over() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	sanity_depleted.emit()
