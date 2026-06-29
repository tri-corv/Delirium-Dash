extends Area2D # La puerta detecta cuando el jugador la toca.

@export var closed_texture: Texture2D = preload("res://assets/sprites/door_open.png") # Textura que se usa al cerrar la puerta.
@export var open_texture: Texture2D = preload("res://assets/sprites/door_closed.png") # Textura que se muestra cuando esta abierta.
@export var closed_scale: Vector2 = Vector2.ONE # Escala visual de la puerta cerrada.
@export var open_scale: Vector2 = Vector2.ONE # Escala visual de la puerta abierta.
@export var close_delay: float = 0.45 # Tiempo de espera antes de cerrar la puerta.
@export var next_scene: String = "" # Escena a cargar despues de entrar.
@export var camera_lift: float = 0.0 # Cuanto sube la camara durante la transicion.
@export var required_clues: int = 0 # Cantidad de pistas necesarias para desbloquear.

@onready var sprite: Sprite2D = $Sprite2D # Sprite visual de la puerta.

var _is_finishing := false # Evita ejecutar la salida mas de una vez.
var _found_clues := 0 # Pistas encontradas hasta el momento.

# Configura la puerta al iniciar.
func _ready() -> void:
	sprite.texture = open_texture # Muestra la textura inicial.
	sprite.scale = open_scale # Aplica la escala inicial.
	body_entered.connect(_on_body_entered) # Escucha cuando un cuerpo entra en la puerta.

# Responde cuando algo toca la puerta.
func _on_body_entered(body: Node2D) -> void:
	if _is_finishing or not body.is_in_group("player"): # Solo permite al jugador entrar una vez.
		return # Ignora el evento.

	if not is_unlocked(): # Si faltan pistas.
		return # No deja terminar el nivel.

	_finish_level(body) # Ejecuta la animacion de salida.

# Recibe el progreso de pistas desde la interfaz del nivel.
func set_clue_progress(found: int, total: int) -> void:
	_found_clues = found # Guarda cuantas pistas se encontraron.
	required_clues = total # Guarda cuantas pistas hacen falta.

# Devuelve si la puerta puede usarse.
func is_unlocked() -> bool:
	return required_clues <= 0 or _found_clues >= required_clues # Si no pide pistas o ya estan todas, abre.

# Anima al jugador entrando por la puerta y cambia de escena.
func _finish_level(player: Node2D) -> void:
	_is_finishing = true # Bloquea nuevas entradas.
	player.freeze() # Detiene al jugador.

	var camera := player.get_node_or_null("Camera2D") as Camera2D # Busca la camara del jugador.
	var player_tween := create_tween() # Crea animacion para jugador/camara.
	player_tween.set_parallel(true) # Permite animar varias propiedades a la vez.
	player_tween.tween_property(player, "modulate:a", 0.0, 0.35) # Hace desaparecer al jugador.
	player_tween.tween_property(player, "scale", player.scale * 0.75, 0.35) # Reduce su tamano para simular profundidad.
	if camera != null: # Si existe camara.
		player_tween.tween_property(camera, "position:y", camera.position.y - camera_lift, 0.35) # Mueve la camara hacia arriba.

	await player_tween.finished # Espera a que termine la animacion.
	await get_tree().create_timer(close_delay).timeout # Espera antes de cerrar.

	await _close_door() # Cierra la puerta con animacion.
	player.queue_free() # Elimina al jugador de la escena actual.

	if not next_scene.is_empty(): # Si hay escena destino configurada.
		get_tree().change_scene_to_file(next_scene) # Cambia al siguiente nivel/pantalla.

# Cierra visualmente la puerta.
func _close_door() -> void:
	sprite.texture = closed_texture # Cambia a textura cerrada.
	sprite.scale = closed_scale # Ajusta escala cerrada.

	var close_tween := create_tween() # Crea animacion de cierre.
	close_tween.tween_property(sprite, "scale", closed_scale * Vector2(0.92, 1.08), 0.08) # Deforma un poco para dar golpe.
	close_tween.tween_property(sprite, "scale", closed_scale, 0.14) # Vuelve a la escala normal.
	await close_tween.finished # Espera a que termine la animacion.
