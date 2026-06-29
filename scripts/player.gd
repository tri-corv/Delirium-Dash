extends CharacterBody2D # El jugador usa fisicas y colisiones de un cuerpo 2D.

# Señal para avisar a la interfaz que cambio la cordura.
signal sanity_changed(current: float, maximum: float)
# Señal para avisar que la cordura llego a cero.
signal sanity_depleted
# Señal para avisar cuantos segundos faltan para recuperar cordura.
signal sanity_regen_timer_changed(seconds_left: int)

@export var max_sanity: float = 100.0 # Cordura maxima del jugador.
@export var sanity_regen_amount: float = 10.0 # Cordura que recupera cada ciclo.
@export var sanity_regen_interval: float = 5.0 # Segundos que tarda cada recuperacion.
@export var manual_move_speed: float = 320.0 # Velocidad usada cuando el movimiento es libre.
@export var free_arrow_movement: bool = false # Permite moverse con las flechas en lugar de avanzar solo.

const MOVE_SPEED: float = 280.0 # Velocidad automatica horizontal.
const JUMP_FORCE: float = -700.0 # Impulso vertical del salto normal.
const GRAVITY: float = 1200.0 # Fuerza que empuja al jugador hacia abajo.

var is_dead: bool = false # Indica si el jugador ya perdio.
var is_paused: bool = false # Indica si el movimiento esta pausado por una interaccion.
var sanity: float = max_sanity # Cordura actual del jugador.
var _sanity_regen_timer: float = 0.0 # Cuenta el tiempo hasta la proxima recuperacion.
var _last_regen_seconds_left := -1 # Ultimo valor mostrado en el contador.

# Se ejecuta una vez cuando el jugador entra en la escena.
func _ready() -> void:
	sanity = max_sanity # Reinicia la cordura al valor maximo.
	_sanity_regen_timer = sanity_regen_interval # Reinicia el contador de recuperacion.
	sanity_changed.emit(sanity, max_sanity) # Actualiza la interfaz desde el inicio.
	_emit_regen_timer() # Muestra el contador inicial.

# Se ejecuta en cada frame de fisicas.
func _physics_process(delta: float) -> void:
	if is_dead or is_paused: # Si murio o esta interactuando, no se mueve.
		return

	if free_arrow_movement: # Modo de movimiento libre para niveles de exploracion.
		velocity = _get_arrow_input_vector() * manual_move_speed # Convierte las flechas en velocidad.
	else: # Modo de avance automatico.
		if not is_on_floor(): # Si esta en el aire, aplica gravedad.
			velocity.y += GRAVITY * delta # Suma aceleracion vertical hacia abajo segun el tiempo.
		velocity.x = MOVE_SPEED # Mantiene al jugador avanzando hacia la derecha.

	if not free_arrow_movement and Input.is_action_just_pressed("jump"): # Detecta salto solo en modo automatico.
		_jump() # Aplica el impulso de salto.

	_update_sanity_regen(delta) # Cuenta el tiempo y recupera cordura cada intervalo.
	move_and_slide() # Mueve el cuerpo y calcula colisiones.

# Hace saltar al jugador.
func _jump() -> void:
	if is_on_floor(): # Solo puede saltar si esta tocando el piso.
		velocity.y = JUMP_FORCE # Aplica el impulso vertical hacia arriba.

# Detiene definitivamente al jugador.
func freeze() -> void:
	is_dead = true # Marca al jugador como bloqueado/muerto.
	velocity = Vector2.ZERO # Elimina todo movimiento.

# Pausa el movimiento durante una interaccion.
func pause_for_interaction() -> void:
	is_paused = true # Activa el estado de pausa.
	velocity = Vector2.ZERO # Detiene al jugador mientras lee o interactua.

# Reactiva el movimiento luego de una interaccion.
func resume_from_interaction() -> void:
	is_paused = false # Desactiva la pausa.

# Lee las flechas del teclado y devuelve una direccion normalizada.
func _get_arrow_input_vector() -> Vector2:
	var direction := Vector2.ZERO # Empieza sin direccion.

	if Input.is_key_pressed(KEY_LEFT): # Flecha izquierda.
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_RIGHT): # Flecha derecha.
		direction.x += 1.0
	if Input.is_key_pressed(KEY_UP): # Flecha arriba.
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_DOWN): # Flecha abajo.
		direction.y += 1.0

	return direction.normalized() # Normaliza para que diagonal no sea mas rapida.

# Cuenta cinco segundos y recupera cordura si el jugador sigue vivo.
func _update_sanity_regen(delta: float) -> void:
	if sanity >= max_sanity: # Si la cordura ya esta completa.
		_sanity_regen_timer = sanity_regen_interval # Mantiene el contador listo para cuando vuelva a bajar.
		_emit_regen_timer()
		return

	_sanity_regen_timer -= delta # Descuenta el tiempo del frame.
	if _sanity_regen_timer <= 0.0: # Si pasaron los segundos necesarios.
		heal_sanity(sanity_regen_amount) # Recupera cordura.
		_sanity_regen_timer = sanity_regen_interval # Reinicia el contador.

	_emit_regen_timer() # Actualiza el contador en la interfaz.

# Avisa al HUD cuantos segundos faltan para la proxima recuperacion.
func _emit_regen_timer() -> void:
	var seconds_left := ceili(_sanity_regen_timer)
	if seconds_left == _last_regen_seconds_left:
		return

	_last_regen_seconds_left = seconds_left
	sanity_regen_timer_changed.emit(seconds_left)

# Aumenta la cordura sin pasar el maximo.
func heal_sanity(amount: float) -> void:
	if is_dead:
		return

	sanity = minf(sanity + amount, max_sanity)
	sanity_changed.emit(sanity, max_sanity)

# Quita cordura al jugador.
func take_sanity_damage(amount: float) -> void:
	if is_dead: # Si ya perdio, ignora daño extra.
		return # Evita repetir el game over.

	sanity = maxf(sanity - amount, 0.0) # Resta cordura sin permitir valores negativos.
	sanity_changed.emit(sanity, max_sanity) # Avisa a la interfaz el nuevo valor.

	if sanity <= 0.0: # Si la cordura llego a cero.
		_trigger_game_over() # Dispara la derrota.

# Activa el estado de game over.
func _trigger_game_over() -> void:
	is_dead = true # Bloquea al jugador.
	velocity = Vector2.ZERO # Detiene cualquier movimiento restante.
	sanity_depleted.emit() # Avisa a la interfaz que debe mostrar game over.
