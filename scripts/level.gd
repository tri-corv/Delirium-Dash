extends Node2D

const TILE_SOURCE_ID := 1
const FLOOR_TILE := Vector2i(0, 0)
const CEILING_TILE := Vector2i(1, 0)
const FLOOR_ROW := 21
const CEILING_ROW := -3
const START_COLUMN := -20
const END_COLUMN := 120

@onready var terrain: TileMapLayer = $Terrain

func _ready() -> void:
	_paint_terrain()

func _paint_terrain() -> void:
	terrain.clear()

	for column in range(START_COLUMN, END_COLUMN + 1):
		terrain.set_cell(Vector2i(column, FLOOR_ROW), TILE_SOURCE_ID, FLOOR_TILE)
		terrain.set_cell(Vector2i(column, FLOOR_ROW + 1), TILE_SOURCE_ID, FLOOR_TILE)
		terrain.set_cell(Vector2i(column, CEILING_ROW), TILE_SOURCE_ID, CEILING_TILE)
		terrain.set_cell(Vector2i(column, CEILING_ROW + 1), TILE_SOURCE_ID, CEILING_TILE)
