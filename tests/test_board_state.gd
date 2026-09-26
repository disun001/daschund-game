extends GutTest

const Cell = BoardState.Cell
const Action = BoardState.Action

func _empty_board(w: int, h: int, cap: int) -> BoardState:
	return BoardState.new(w, h, cap)

func test_first_tap_on_empty_board_places_first_body_cell() -> void:
	var board := _empty_board(5, 5, 10)
	var action := board.resolve_tap(Vector2i(2, 2))

	assert_eq(action, Action.PLACE)
	assert_eq(board.length_used, 1)
	assert_eq(board.get_cell(Vector2i(2, 2)), Cell.BODY)

func test_tap_on_adjacent_empty_cell_extends() -> void:
	var board := _empty_board(5, 5, 10)
	board.resolve_tap(Vector2i(2, 2))

	var action := board.resolve_tap(Vector2i(3, 2))

	assert_eq(action, Action.EXTEND)
	assert_eq(board.length_used, 2)
	assert_eq(board.get_cell(Vector2i(3, 2)), Cell.BODY)

func test_tap_on_diagonally_adjacent_empty_cell_extends() -> void:
	var board := _empty_board(5, 5, 10)
	board.resolve_tap(Vector2i(2, 2))

	var action := board.resolve_tap(Vector2i(3, 3))

	assert_eq(action, Action.EXTEND)
	assert_eq(board.length_used, 2)

func test_tap_on_nonadjacent_empty_cell_is_noop() -> void:
	var board := _empty_board(5, 5, 10)
	board.resolve_tap(Vector2i(0, 0))

	var action := board.resolve_tap(Vector2i(4, 4))

	assert_eq(action, Action.INVALID)
	assert_eq(board.length_used, 1)
	assert_eq(board.get_cell(Vector2i(4, 4)), Cell.EMPTY)

func test_tap_on_nonadjacent_water_is_noop() -> void:
	var grid := [
		[Cell.EMPTY, Cell.EMPTY, Cell.EMPTY],
		[Cell.EMPTY, Cell.EMPTY, Cell.EMPTY],
		[Cell.WATER, Cell.EMPTY, Cell.EMPTY],
	]
	var board := BoardState.new(3, 3, 10, grid)
	board.resolve_tap(Vector2i(2, 0))

	var action := board.resolve_tap(Vector2i(0, 2))

	assert_eq(action, Action.INVALID)
	assert_eq(board.length_used, 1)
	assert_eq(board.get_cell(Vector2i(0, 2)), Cell.WATER)

func test_tap_on_water_is_noop() -> void:
	var grid := [[Cell.EMPTY, Cell.WATER], [Cell.EMPTY, Cell.EMPTY]]
	var board := BoardState.new(2, 2, 10, grid)
	board.resolve_tap(Vector2i(0, 0))

	var action := board.resolve_tap(Vector2i(1, 0))

	assert_eq(action, Action.INVALID)
	assert_eq(board.length_used, 1)
	assert_eq(board.get_cell(Vector2i(1, 0)), Cell.WATER)

func test_tap_on_apple_cherry_bee_is_noop() -> void:
	var grid := [[Cell.EMPTY, Cell.APPLE, Cell.CHERRY], [Cell.BEE, Cell.EMPTY, Cell.EMPTY]]
	var board := BoardState.new(3, 2, 10, grid)
	board.resolve_tap(Vector2i(0, 0))

	assert_eq(board.resolve_tap(Vector2i(1, 0)), Action.INVALID)
	assert_eq(board.resolve_tap(Vector2i(0, 1)), Action.INVALID)
	assert_eq(board.length_used, 1)
	assert_eq(board.get_cell(Vector2i(1, 0)), Cell.APPLE)
	assert_eq(board.get_cell(Vector2i(0, 1)), Cell.BEE)

func test_extend_past_length_cap_is_rejected() -> void:
	var board := _empty_board(5, 5, 2)
	board.resolve_tap(Vector2i(0, 0))
	board.resolve_tap(Vector2i(1, 0))

	var action := board.resolve_tap(Vector2i(2, 0))

	assert_eq(action, Action.INVALID)
	assert_eq(board.length_used, 2)
	assert_eq(board.get_cell(Vector2i(2, 0)), Cell.EMPTY)

func test_tap_on_middle_body_cell_removes_only_that_cell_and_refunds_length() -> void:
	var board := _empty_board(5, 5, 10)
	for x in range(4):
		board.resolve_tap(Vector2i(x, 0))

	var action := board.resolve_tap(Vector2i(1, 0))

	assert_eq(action, Action.REMOVE)
	assert_eq(board.length_used, 3)
	assert_eq(board.get_cell(Vector2i(1, 0)), Cell.EMPTY)
	assert_eq(board.get_cell(Vector2i(0, 0)), Cell.BODY)
	assert_eq(board.get_cell(Vector2i(2, 0)), Cell.BODY)
	assert_eq(board.get_cell(Vector2i(3, 0)), Cell.BODY)

func test_removing_middle_cell_splits_dog_and_blocks_submit() -> void:
	var board := _empty_board(5, 5, 10)
	for x in range(4):
		board.resolve_tap(Vector2i(x, 0))
	assert_true(board.can_submit())

	board.resolve_tap(Vector2i(1, 0))

	assert_false(board.is_dog_connected())
	assert_false(board.can_submit())

func test_diagonal_neighbours_keep_dog_connected_after_corner_removal() -> void:
	var board := _empty_board(5, 5, 10)
	board.resolve_tap(Vector2i(0, 0))
	board.resolve_tap(Vector2i(1, 0))
	board.resolve_tap(Vector2i(1, 1))

	board.resolve_tap(Vector2i(1, 0))

	assert_true(board.can_submit())

func test_can_reconnect_split_dog_by_replacing_removed_cell() -> void:
	var board := _empty_board(5, 5, 10)
	for x in range(3):
		board.resolve_tap(Vector2i(x, 0))
	board.resolve_tap(Vector2i(1, 0))

	var action := board.resolve_tap(Vector2i(1, 0))

	assert_eq(action, Action.EXTEND)
	assert_true(board.can_submit())

func test_removing_all_cells_allows_placing_anywhere_again() -> void:
	var board := _empty_board(5, 5, 10)
	board.resolve_tap(Vector2i(0, 0))
	board.resolve_tap(Vector2i(0, 0))

	assert_false(board.has_dog())
	assert_eq(board.resolve_tap(Vector2i(4, 4)), Action.PLACE)

func test_cannot_extend_from_middle_cell() -> void:
	var board := _empty_board(7, 5, 10)
	for x in range(5):
		board.resolve_tap(Vector2i(x, 0))

	assert_eq(board.resolve_tap(Vector2i(2, 1)), Action.INVALID)
	assert_eq(board.resolve_tap(Vector2i(5, 0)), Action.EXTEND)

func test_ring_has_no_ends_and_cannot_grow() -> void:
	var board := _empty_board(5, 5, 10)
	for pos in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)]:
		board.resolve_tap(pos)

	assert_false(board.is_end(Vector2i(0, 0)))
	assert_eq(board.resolve_tap(Vector2i(2, 0)), Action.INVALID)

func test_removal_frees_length_under_cap() -> void:
	var board := _empty_board(5, 5, 3)
	for x in range(3):
		board.resolve_tap(Vector2i(x, 0))
	board.resolve_tap(Vector2i(0, 0))

	assert_eq(board.resolve_tap(Vector2i(3, 0)), Action.EXTEND)
	assert_eq(board.length_used, 3)

func test_out_of_bounds_tap_is_noop() -> void:
	var board := _empty_board(3, 3, 10)
	board.resolve_tap(Vector2i(0, 0))

	var action := board.resolve_tap(Vector2i(-1, 0))

	assert_eq(action, Action.INVALID)
	assert_eq(board.length_used, 1)
