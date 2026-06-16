extends Node2D

const TILE_SOURCE_ID := 1

# --- CONFIGURACIÓN DE TILES ---
const FLOOR_TILE := Vector2i(0, 0)
const FLOOR_CRACKED := Vector2i(1, 0)

const CEILING_TILE := Vector2i(0, 0)        
const CEILING_CRACKED_1 := Vector2i(1, 0)

const WALL_TILE := Vector2i(2,0)

# --- CONFIGURACIÓN DEL MAPA ---
const FLOOR_ROW := 21
const CEILING_ROW := 10
const START_COLUMN := -30
const END_COLUMN := 500

@onready var terrain: TileMapLayer = $Terrain

func _ready() -> void:
	_paint_terrain()

func _paint_terrain() -> void:
	terrain.clear()

	for column in range(START_COLUMN, END_COLUMN + 1):
		# --- 1. PINTAR PAREDES ---
		# Rellena todo el espacio intermedio con el tile de pared - Filas 12 a 20
		for wall_y in range(CEILING_ROW + 2, FLOOR_ROW): 
			terrain.set_cell(Vector2i(column, wall_y), TILE_SOURCE_ID, WALL_TILE)
		# --- 2. LÓGICA ALEATORIA PARA EL SUELO ---
		var chosen_floor = FLOOR_TILE
		if randf() < 0.10: # 10% de probabilidad de que salga roto
			chosen_floor = FLOOR_CRACKED
		
		# Pinta la línea del suelo y la capa inferior de soporte
		terrain.set_cell(Vector2i(column, FLOOR_ROW), TILE_SOURCE_ID, chosen_floor)
		terrain.set_cell(Vector2i(column, FLOOR_ROW + 1), TILE_SOURCE_ID, FLOOR_TILE)
		
		# --- 3. LÓGICA ALEATORIA PARA EL TECHO ---
		var chosen_ceiling = CEILING_TILE
		if randf() < 0.12: # 12% de probabilidad de que salga roto
			chosen_ceiling = CEILING_CRACKED_1
			
		# Pinta la línea del techo y la capa superior de soporte
		terrain.set_cell(Vector2i(column, CEILING_ROW), TILE_SOURCE_ID, chosen_ceiling)
		terrain.set_cell(Vector2i(column, CEILING_ROW + 1), TILE_SOURCE_ID, CEILING_TILE)
