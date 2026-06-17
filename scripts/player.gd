extends CharacterBody2D

# -- Configuración exportable por nivel --
@export var gravity_mode: bool = false  # false = salto, true = flip gravedad

const MOVE_SPEED: float = 280.0
const JUMP_FORCE: float = -520.0
const GRAVITY: float = 1200.0

var is_dead: bool = false
var is_paused: bool = false
var gravity_direction: int = 1  # 1 = normal, -1 = invertida

func _physics_process(delta: float) -> void:
	if is_dead or is_paused:
		return

	# Gravedad (respeta la dirección actual)
	if not is_on_floor() and not is_on_ceiling():
		velocity.y += GRAVITY * gravity_direction * delta

	# Movimiento horizontal automático
	velocity.x = MOVE_SPEED

	# Acción según modo del pabellón
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
	# Rotamos el sprite para que se vea boca abajo
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
