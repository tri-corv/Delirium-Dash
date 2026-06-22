extends CharacterBody2D

signal sanity_changed(current: float, maximum: float)
signal sanity_depleted

@export var gravity_mode: bool = false
@export var max_sanity: float = 100.0
@export var obstacle_sanity_damage: float = 25.0
@export var obstacle_damage_cooldown: float = 0.8
@export var manual_move_speed: float = 320.0

const MOVE_SPEED: float = 280.0
const JUMP_FORCE: float = -700.0
const GRAVITY: float = 1200.0

var is_dead: bool = false
var is_paused: bool = false
var gravity_direction: int = 1
var sanity: float = max_sanity
var _obstacle_damage_timer := 0.0
var _auto_run_enabled := true
var _manual_horizontal_enabled := false

func _ready() -> void:
	sanity = max_sanity
	sanity_changed.emit(sanity, max_sanity)

func _physics_process(delta: float) -> void:
	if is_dead or is_paused:
		return

	if not is_on_floor() and not is_on_ceiling():
		velocity.y += GRAVITY * gravity_direction * delta

	if _manual_horizontal_enabled:
		velocity.x = _get_horizontal_input() * manual_move_speed
	elif _auto_run_enabled:
		velocity.x = MOVE_SPEED
	else:
		velocity.x = 0.0

	if not _manual_horizontal_enabled and Input.is_action_just_pressed("jump"):
		if gravity_mode:
			_flip_gravity()
		else:
			_jump()

	_obstacle_damage_timer = maxf(_obstacle_damage_timer - delta, 0.0)
	move_and_slide()
	_apply_obstacle_collision_damage()

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

func start_dodge_mode() -> void:
	_auto_run_enabled = false
	_manual_horizontal_enabled = true
	velocity.x = 0.0

func end_dodge_mode() -> void:
	_manual_horizontal_enabled = false
	_auto_run_enabled = true

func _get_horizontal_input() -> float:
	var direction := 0.0

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction += 1.0

	return clampf(direction, -1.0, 1.0)

func _apply_obstacle_collision_damage() -> void:
	if _obstacle_damage_timer > 0.0:
		return

	for collision_index in range(get_slide_collision_count()):
		var collision := get_slide_collision(collision_index)
		if _is_sanity_obstacle(collision.get_collider()):
			take_sanity_damage(obstacle_sanity_damage)
			_obstacle_damage_timer = obstacle_damage_cooldown
			return

func _is_sanity_obstacle(collider: Object) -> bool:
	var node := collider as Node
	if node == null:
		return false

	if node.is_in_group("sanity_obstacle") or String(node.name).begins_with("Obstacle"):
		return true

	var parent := node.get_parent()
	while parent != null:
		if parent.is_in_group("sanity_obstacle") or String(parent.name) == "Obstacles":
			return true
		parent = parent.get_parent()

	return false

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
