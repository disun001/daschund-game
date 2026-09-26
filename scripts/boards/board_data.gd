class_name BoardData
extends RefCounted

## Plain data for one hand-authored board. Holds no gameplay rules; edit
## board content in board_catalog.gd without touching BoardState.
## Layout glyphs: '.' empty, 'W' Water, 'A' Apple, 'C' Cherry, 'B' Bee.

const _GLYPHS := {
	".": BoardState.Cell.EMPTY,
	"W": BoardState.Cell.WATER,
	"A": BoardState.Cell.APPLE,
	"C": BoardState.Cell.CHERRY,
	"B": BoardState.Cell.BEE,
}

var rows: Array[String]
var dog_length_cap: int

func _init(p_rows: Array[String], p_dog_length_cap: int) -> void:
	rows = p_rows
	dog_length_cap = p_dog_length_cap

func width() -> int:
	return rows[0].length()

func height() -> int:
	return rows.size()

## Builds a fresh BoardState (no Dog placed) from this data.
func make_state() -> BoardState:
	var grid := []
	for row in rows:
		var cells := []
		for glyph in row:
			cells.append(_GLYPHS[glyph])
		grid.append(cells)
	return BoardState.new(width(), height(), dog_length_cap, grid)
