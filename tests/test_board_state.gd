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

# --- Enclosure detection + scoring ---

# Builds a board from rows: '.' empty, '#' body, '~' water, 'A' apple, 'C' cherry, 'B' bee.
func _board_from(rows: Array) -> BoardState:
	var grid := []
	var body := 0
	for row in rows:
		var r := []
		for ch in row:
			match ch:
				"#":
					r.append(Cell.BODY)
					body += 1
				"~":
					r.append(Cell.WATER)
				"A":
					r.append(Cell.APPLE)
				"C":
					r.append(Cell.CHERRY)
				"B":
					r.append(Cell.BEE)
				_:
					r.append(Cell.EMPTY)
		grid.append(r)
	var b := BoardState.new(rows[0].length(), rows.size(), 99, grid)
	b.length_used = body
	return b

func test_open_board_has_no_enclosures() -> void:
	var report := _board_from(["...", "...", "..."]).score_report()
	assert_eq(report.enclosures.size(), 0)
	assert_eq(report.total, 0)

func test_body_ring_encloses_center() -> void:
	var report := _board_from([".....", ".###.", ".#.#.", ".###.", "....."]).score_report()
	assert_eq(report.enclosures.size(), 1)
	assert_eq(report.total, 1)

func test_border_only_anchor_path_seals_region() -> void:
	var report := _board_from(["..#..", "..#..", "..#.."]).score_report()
	assert_eq(report.enclosures.size(), 0, "a wall splitting the board leaves both sides open to the edge")
	var sealed := _board_from(["#####", "#...#", "#...#", "#####"]).score_report()
	assert_eq(sealed.total, 6)

func test_board_edge_alone_never_seals() -> void:
	var report := _board_from([".....", ".....", "..#..", "....."]).score_report()
	assert_eq(report.total, 0)

func test_water_only_and_mixed_anchors_seal() -> void:
	var water := _board_from([".....", ".~~~.", ".~.~.", ".~~~.", "....."]).score_report()
	assert_eq(water.total, 1)
	var mixed := _board_from([".....", ".~##.", ".~.#.", ".###.", "....."]).score_report()
	assert_eq(mixed.total, 1)

func test_diagonal_pair_closes_corner_gap() -> void:
	# Center cell (2,2) is sealed only via diagonal joins at every corner.
	var closed := _board_from([".....", "..#..", ".#.#.", "..#..", "....."]).score_report()
	assert_eq(closed.total, 1, "diagonal walls seal the gaps")
	var open := _board_from([".....", "..#..", ".#.#.", ".....", "....."]).score_report()
	assert_eq(open.total, 0, "an unclosed corner leaks")

func test_diagonal_body_water_pair_seals() -> void:
	var report := _board_from([".....", "..~..", ".#.#.", "..~..", "....."]).score_report()
	assert_eq(report.total, 1)

func test_multiple_disjoint_enclosures_are_summed() -> void:
	var report := _board_from([
		"#####.#####",
		"#...#.#...#",
		"#####.#####",
	]).score_report()
	assert_eq(report.enclosures.size(), 2)
	assert_eq(report.enclosures[0].score, 3)
	assert_eq(report.enclosures[1].score, 3)
	assert_eq(report.total, 6)

func test_split_dog_bodies_still_count_as_walls() -> void:
	var b := _board_from([".....", ".###.", ".#.#.", ".###.", "....."])
	b.resolve_tap(Vector2i(1, 2)) # remove a wall cell
	assert_eq(b.score_report().total, 0)

func test_enclosed_apple_adds_five_instead_of_plain_point() -> void:
	var report := _board_from(["#####", "#.A.#", "#####"]).score_report()
	assert_eq(report.total, 2 + BoardState.POINTS_APPLE)

func test_enclosed_cherry_adds_bonus() -> void:
	var report := _board_from(["#####", "#.C.#", "#####"]).score_report()
	assert_eq(report.total, 2 + BoardState.POINTS_CHERRY)

func test_enclosed_bee_applies_penalty() -> void:
	var report := _board_from(["#######", "#.....#", "#..B..#", "#######"]).score_report()
	assert_eq(report.total, 9 + BoardState.POINTS_BEE)

func test_bee_enclosure_still_scores_positive_when_outweighed() -> void:
	var report := _board_from(["#####", "#BC.#", "#####"]).score_report()
	assert_eq(report.enclosures.size(), 1)
	assert_eq(report.total, BoardState.POINTS_CELL + BoardState.POINTS_CHERRY + BoardState.POINTS_BEE)

func test_bee_enclosure_can_go_negative_without_voiding() -> void:
	var report := _board_from(["####", "#B.#", "####"]).score_report()
	assert_eq(report.total, BoardState.POINTS_CELL + BoardState.POINTS_BEE)

func test_unenclosed_elements_score_nothing() -> void:
	var report := _board_from(["A.C.B"]).score_report()
	assert_eq(report.total, 0)

func test_modifiers_are_scored_per_enclosure() -> void:
	var report := _board_from(["#####.#####", "#.A.#.#.B.#", "#####.#####"]).score_report()
	assert_eq(report.enclosures[0].score, 2 * BoardState.POINTS_CELL + BoardState.POINTS_APPLE)
	assert_eq(report.enclosures[1].score, 2 * BoardState.POINTS_CELL + BoardState.POINTS_BEE)
	assert_eq(report.total, 4 * BoardState.POINTS_CELL + BoardState.POINTS_APPLE + BoardState.POINTS_BEE)

# --- Done: freeze + snapshot ---

func _connected_dog_board() -> BoardState:
	var board := _empty_board(5, 5, 10)
	board.resolve_tap(Vector2i(2, 2))
	board.resolve_tap(Vector2i(3, 2))
	return board

func test_submit_freezes_board_and_snapshots_report() -> void:
	var board := _connected_dog_board()
	var live_total := board.score_report().total

	assert_true(board.submit())
	assert_true(board.is_frozen())
	assert_eq(board.final_report.total, live_total)

func test_submit_rejected_for_split_or_empty_dog() -> void:
	var empty := _empty_board(5, 5, 10)
	assert_false(empty.submit(), "no Dog")
	assert_false(empty.is_frozen())

	var split := _connected_dog_board()
	split.resolve_tap(Vector2i(4, 2))
	split.resolve_tap(Vector2i(3, 2))
	assert_false(split.is_dog_connected())
	assert_false(split.submit())
	assert_false(split.is_frozen())

func test_taps_after_submit_have_no_effect() -> void:
	var board := _connected_dog_board()
	board.submit()

	assert_eq(board.resolve_tap(Vector2i(4, 2)), Action.INVALID, "extend ignored")
	assert_eq(board.resolve_tap(Vector2i(2, 2)), Action.INVALID, "remove ignored")
	assert_eq(board.length_used, 2)
	assert_eq(board.get_cell(Vector2i(2, 2)), Cell.BODY)

func test_final_report_is_a_snapshot_not_live() -> void:
	var board := _connected_dog_board()
	board.submit()
	var snapshot := board.final_report
	var total := snapshot.total

	board.score_report()  # live recompute must not alter snapshot
	assert_same(board.final_report, snapshot)
	assert_eq(board.final_report.total, total)
