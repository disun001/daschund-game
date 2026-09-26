extends GutTest

const Cell = BoardState.Cell

func test_sync_from_board_renders_all_six_cell_types() -> void:
	var grid: Array = [
		[Cell.EMPTY, Cell.BODY, Cell.WATER],
		[Cell.APPLE, Cell.CHERRY, Cell.BEE],
	]
	var board := BoardState.new(3, 2, 10, grid)

	var view: BoardView = autofree(BoardView.new())
	add_child_autofree(view)
	view.sync_from_board(board)

	for y in range(2):
		for x in range(3):
			var pos := Vector2i(x, y)
			var expected_atlas_x: int = BoardView.CELL_ORDER.find(board.get_cell(pos))
			assert_eq(view.get_cell_source_id(pos), 0, "source id at %s" % [pos])
			assert_eq(view.get_cell_atlas_coords(pos), Vector2i(expected_atlas_x, 0), "atlas coords at %s" % [pos])

func test_sync_from_board_clears_stale_cells() -> void:
	var board := BoardState.new(2, 1, 10)
	var view: BoardView = autofree(BoardView.new())
	add_child_autofree(view)

	board.resolve_tap(Vector2i(0, 0))
	view.sync_from_board(board)
	assert_ne(view.get_cell_source_id(Vector2i(0, 0)), -1)

	var fresh_board := BoardState.new(2, 1, 10)
	view.sync_from_board(fresh_board)
	assert_eq(view.get_cell_atlas_coords(Vector2i(0, 0)), Vector2i(BoardView.CELL_ORDER.find(Cell.EMPTY), 0))
