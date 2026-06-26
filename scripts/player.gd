extends CharacterBody2D

# Señales que avisan cuando disminuye la cordura
signal sanity_changed(current: float, maximum: float)
signal sanity_depleted

@export var gravity_mode: bool = false
@export var max_sanity: float = 100.0 # Cordura max.= 100%
@export var obstacle_sanity_damage: float = 25.0 # Daño en la cordura al tocar obstáculos = 25%
@export var obstacle_damage_cooldown: float = 0.8 # Tiempo min. entre daños
@export var manual_move_speed: float = 320.0 # Velocidad del jugador en 'modo libre'
@export var free_arrow_movement: bool = false # Permite moverse con flechas (level_2)

const MOVE_SPEED: float = 280.0 # Velocidad
const JUMP_FORCE: float = -700.0 # Salto
const GRAVITY: float = 1200.0 # Gravedad --> atrae al jugador hacia abajo cuando salta

var is_dead: bool = false
var is_paused: bool = false
var gravity_direction: int = 1 # Gravedad hacia abajo (1)
var sanity: float = max_sanity
var _obstacle_damage_timer := 0.0 # Evitar daño continuo

# Inicia la cordura al comenzar la escena.
func _ready() -> void:
	sanity = max_sanity
	sanity_changed.emit(sanity, max_sanity)

func _physics_process(delta: float) -> void:
	# Si el jugador murió o está en pausa no se mueve.
	if is_dead or is_paused:
		return

	# Movimiento libre con flechas
	if free_arrow_movement:
		velocity = _get_arrow_input_vector() * manual_move_speed
	
	# Aplica gravedad si no toca el piso o el techo
	else:
		if not is_on_floor() and not is_on_ceiling():
			velocity.y += GRAVITY * gravity_direction * delta
		# Movimiento automático hacia la derecha (level_1)
		velocity.x = MOVE_SPEED

# Acción de salto.
# En modo gravedad, la invierte. En modo normal, hace saltar al jugador.
	if not free_arrow_movement and Input.is_action_just_pressed("jump"):
		if gravity_mode:
			_flip_gravity()
		else:
			_jump()

# Disminuye el tiempo restante hasta poder recibir daño nuevamente.
	_obstacle_damage_timer = maxf(_obstacle_damage_timer - delta, 0.0)
	move_and_slide() # Mueve al jugador y detecta colisiones
	_apply_obstacle_collision_damage() # Revisa si chocó con obstáculos que dañan cordura.

func _jump() -> void:
	# Solo permite saltar si el jugador está en el piso.
	if is_on_floor():
		velocity.y = JUMP_FORCE

func _flip_gravity() -> void:
	gravity_direction *= -1
	velocity.y = 0.0
	scale.y *= -1

func freeze() -> void:
	is_dead = true
	velocity = Vector2.ZERO

# Pausa el movimiento durante las interacciones.
func pause_for_interaction() -> void:
	is_paused = true
	velocity = Vector2.ZERO

# Reactiva el movimiento luego de una interacción.
func resume_from_interaction() -> void:
	is_paused = false

func _get_arrow_input_vector() -> Vector2:
	# Obtiene la dirección según la flecha presionada.
	var direction := Vector2.ZERO

	if Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0

	return direction.normalized()

func _apply_obstacle_collision_damage() -> void:
	if _obstacle_damage_timer > 0.0:
		return
	# Recorre las colisiones del frame.
	for collision_index in range(get_slide_collision_count()):
		var collision := get_slide_collision(collision_index)
		# Si chocó con un obstáculo, recibe daño.
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
	# Si está muerto, no recibe más daño-
	if is_dead:
		return
	
	# Resta la cordura, siempre >= 0.
	sanity = maxf(sanity - amount, 0.0)
	# Avisa a la interfaz el cambio de cordura.
	sanity_changed.emit(sanity, max_sanity)
	# Cuando la cordura llega a 0 --> GAME OVER
	if sanity <= 0.0:
		_trigger_game_over()

func _trigger_game_over() -> void:
	# Detiene al jugador y da la señal de game over.
	is_dead = true
	velocity = Vector2.ZERO
	sanity_depleted.emit()
