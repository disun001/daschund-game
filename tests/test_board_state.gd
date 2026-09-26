extends GutTest

const Cell = BoardState.Cell
const Action = BoardState.Action

func _empty_board(w: int, h: int, cap: int) -> BoardState:
	return BoardState.new(w, h, cap)

func test_first_tap_on_empty_board_places_head_and_tail() -> void:
	var board := _empty_board(5, 5, 10)
	var action := board.resolve_tap(Vector2i(2, 2))

	assert_eq(action, Action.PLACE)
	assert_eq(board.head(), Vector2i(2, 2))
	assert_eq(board.tail(), Vector2i(2, 2))
	assert_eq(board.length_used, 1)
	assert_eq(board.get_cell(Vector2i(2, 2)), Cell.BODY)

func test_tap_on_adjacent_empty_cell_extends() -> void:
	var board := _empty_board(5, 5, 10)
	board.resolve_tap(Vector2i(2, 2))

	var action := board.resolve_tap(Vector2i(3, 2))

	assert_eq(action, Action.EXTEND)
	assert_eq(board.head(), Vector2i(3, 2))
	assert_eq(board.tail(), Vector2i(2, 2))
	assert_eq(board.length_used, 2)
	assert_eq(board.get_cell(Vector2i(3, 2)), Cell.BODY)

func test_tap_on_diagonally_adjacent_empty_cell_extends() -> void:
	var board := _empty_board(5, 5, 10)
	board.resolve_tap(Vector2i(2, 2))

	var action := board.resolve_tap(Vector2i(3, 3))

	assert_eq(action, Action.EXTEND)
	assert_eq(board.head(), Vector2i(3, 3))
	assert_eq(board.length_used, 2)

func test_tap_on_nonadjacent_empty_cell_is_noop() -> void:
	var board := _empty_board(5, 5, 10)
	board.resolve_tap(Vector2i(0, 0))

	var action := board.resolve_tap(Vector2i(4, 4))

	assert_eq(action, Action.INVALID)
	assert_eq(board.head(), Vector2i(0, 0))
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
	assert_eq(board.head(), Vector2i(1, 0))
	assert_eq(board.get_cell(Vector2i(2, 0)), Cell.EMPTY)

func test_tap_on_own_body_cell_truncates_and_refunds_length() -> void:
	var board := _empty_board(5, 5, 10)
	board.resolve_tap(Vector2i(0, 0))
	board.resolve_tap(Vector2i(1, 0))
	board.resolve_tap(Vector2i(2, 0))
	board.resolve_tap(Vector2i(3, 0))

	var action := board.resolve_tap(Vector2i(1, 0))

	assert_eq(action, Action.TRUNCATE)
	assert_eq(board.head(), Vector2i(1, 0))
	assert_eq(board.tail(), Vector2i(0, 0))
	assert_eq(board.length_used, 2)
	assert_eq(board.get_cell(Vector2i(2, 0)), Cell.EMPTY)
	assert_eq(board.get_cell(Vector2i(3, 0)), Cell.EMPTY)
	assert_eq(board.get_cell(Vector2i(1, 0)), Cell.BODY)

func test_truncate_to_tail_leaves_dog_length_one() -> void:
	var board := _empty_board(5, 5, 10)
	board.resolve_tap(Vector2i(0, 0))
	board.resolve_tap(Vector2i(1, 0))
	board.resolve_tap(Vector2i(2, 0))

	board.resolve_tap(Vector2i(0, 0))

	assert_eq(board.head(), Vector2i(0, 0))
	assert_eq(board.tail(), Vector2i(0, 0))
	assert_eq(board.length_used, 1)

func test_truncated_length_can_be_reextended() -> void:
	var board := _empty_board(5, 5, 3)
	board.resolve_tap(Vector2i(0, 0))
	board.resolve_tap(Vector2i(1, 0))
	board.resolve_tap(Vector2i(2, 0))
	board.resolve_tap(Vector2i(0, 0))

	var action := board.resolve_tap(Vector2i(0, 1))

	assert_eq(action, Action.EXTEND)
	assert_eq(board.length_used, 2)

func test_out_of_bounds_tap_is_noop() -> void:
	var board := _empty_board(3, 3, 10)
	board.resolve_tap(Vector2i(0, 0))

	var action := board.resolve_tap(Vector2i(-1, 0))

	assert_eq(action, Action.INVALID)
	assert_eq(board.length_used, 1)
