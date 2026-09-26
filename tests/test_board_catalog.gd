extends GutTest

const Cell = BoardState.Cell

func test_catalog_has_five_to_ten_boards() -> void:
	var n := BoardCatalog.all().size()
	assert_between(n, 5, 10)

func test_first_board_loads_with_intended_layout_cap_and_no_dog() -> void:
	var data := BoardCatalog.all()[0]
	var board := data.make_state()
	assert_eq(board.width, 6)
	assert_eq(board.height, 6)
	assert_eq(board.length_cap, 8)
	assert_false(board.has_dog())
	assert_eq(board.get_cell(Vector2i(0, 2)), Cell.WATER)
	assert_eq(board.get_cell(Vector2i(2, 2)), Cell.APPLE)
	assert_eq(board.get_cell(Vector2i(3, 3)), Cell.EMPTY)

## Data-authoring guard: each board loads with its intended layout and cap.
## Expected values are independent literals, not read back from the catalog.
const EXPECTED := [
	{"size": Vector2i(6, 6), "cap": 8, "cells": {Vector2i(0, 2): Cell.WATER, Vector2i(1, 2): Cell.WATER, Vector2i(2, 2): Cell.APPLE}},
	{"size": Vector2i(6, 6), "cap": 8, "cells": {Vector2i(0, 0): Cell.WATER, Vector2i(1, 0): Cell.WATER, Vector2i(2, 0): Cell.WATER, Vector2i(0, 1): Cell.WATER, Vector2i(2, 1): Cell.CHERRY, Vector2i(0, 2): Cell.WATER}},
	{"size": Vector2i(6, 6), "cap": 9, "cells": {Vector2i(1, 1): Cell.WATER, Vector2i(2, 1): Cell.WATER, Vector2i(1, 2): Cell.WATER, Vector2i(2, 2): Cell.WATER, Vector2i(4, 2): Cell.BEE, Vector2i(2, 4): Cell.APPLE}},
	{"size": Vector2i(6, 6), "cap": 8, "cells": {Vector2i(0, 0): Cell.WATER, Vector2i(0, 1): Cell.WATER, Vector2i(0, 2): Cell.WATER, Vector2i(0, 3): Cell.WATER, Vector2i(0, 4): Cell.WATER, Vector2i(1, 2): Cell.BEE, Vector2i(2, 2): Cell.CHERRY}},
	{"size": Vector2i(6, 6), "cap": 10, "cells": {Vector2i(2, 0): Cell.WATER, Vector2i(3, 0): Cell.WATER, Vector2i(2, 1): Cell.APPLE, Vector2i(3, 4): Cell.APPLE, Vector2i(2, 5): Cell.WATER, Vector2i(3, 5): Cell.WATER}},
	{"size": Vector2i(8, 8), "cap": 10, "cells": {Vector2i(1, 1): Cell.WATER, Vector2i(1, 2): Cell.WATER, Vector2i(6, 1): Cell.CHERRY, Vector2i(4, 2): Cell.BEE, Vector2i(2, 4): Cell.APPLE, Vector2i(6, 4): Cell.WATER, Vector2i(6, 5): Cell.WATER}},
]

func test_every_board_loads_with_intended_layout_and_cap() -> void:
	var boards := BoardCatalog.all()
	assert_eq(boards.size(), EXPECTED.size(), "guard covers every board")
	for i in range(min(boards.size(), EXPECTED.size())):
		var board := boards[i].make_state()
		var exp: Dictionary = EXPECTED[i]
		assert_eq(Vector2i(board.width, board.height), exp.size, "board %d size" % i)
		assert_eq(board.length_cap, exp.cap, "board %d cap" % i)
		assert_false(board.has_dog(), "board %d has no Dog" % i)
		var non_empty := 0
		for y in range(board.height):
			for x in range(board.width):
				var pos := Vector2i(x, y)
				if board.get_cell(pos) != Cell.EMPTY:
					non_empty += 1
					assert_eq(exp.cells.get(pos, -1), board.get_cell(pos), "board %d cell %s" % [i, pos])
		assert_eq(non_empty, exp.cells.size(), "board %d element count" % i)
