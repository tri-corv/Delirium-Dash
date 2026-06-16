extends Node2D

const CEILING_SOURCE_ID := 1
const FLOOR_SOURCE_ID := 10

const FLOOR_TILE := Vector2i(0, 0)
const FLOOR_CRACKED := Vector2i(1, 0)
const CEILING_TILE := Vector2i(0, 0)
const CEILING_CRACKED := Vector2i(1, 0)

const FLOOR_ROW := 21
const CEILING_ROW := 6
const START_COLUMN := -30
const END_COLUMN := 500

@onready var terrain: TileMapLayer = $Terrain

func _ready() -> void:
	_paint_terrain()

func _paint_terrain() -> void:
	for column in range(START_COLUMN, END_COLUMN + 1):
		var floor_tile := FLOOR_TILE
		if randf() < 0.10:
			floor_tile = FLOOR_CRACKED

		terrain.set_cell(Vector2i(column, FLOOR_ROW), FLOOR_SOURCE_ID, floor_tile)
		terrain.set_cell(Vector2i(column, FLOOR_ROW + 1), FLOOR_SOURCE_ID, FLOOR_TILE)

		var ceiling_tile := CEILING_TILE
		if randf() < 0.12:
			ceiling_tile = CEILING_CRACKED

		terrain.set_cell(Vector2i(column, CEILING_ROW), CEILING_SOURCE_ID, ceiling_tile)
		terrain.set_cell(Vector2i(column, CEILING_ROW + 1), CEILING_SOURCE_ID, CEILING_TILE)
