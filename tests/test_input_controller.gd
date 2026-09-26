extends GutTest

func test_tap_converts_local_position_to_grid_cell_and_resolves() -> void:
	var board := BoardState.new(5, 5, 10)
	var controller: InputController = autofree(InputController.new())
	add_child_autofree(controller)
	controller.cell_pixel_size = 16
	controller.set_board(board)

	controller.handle_tap_at_local_position(Vector2(40, 24))

	assert_eq(board.head(), Vector2i(2, 1))
	assert_eq(board.length_used, 1)

func test_invalid_tap_does_not_emit_board_changed() -> void:
	var board := BoardState.new(5, 5, 10)
	var controller: InputController = autofree(InputController.new())
	add_child_autofree(controller)
	controller.set_board(board)
	watch_signals(controller)

	controller.handle_tap(Vector2i(0, 0))
	controller.handle_tap(Vector2i(4, 4))

	assert_signal_emit_count(controller, "board_changed", 1)

func test_tap_with_no_board_set_does_not_error() -> void:
	var controller: InputController = autofree(InputController.new())
	add_child_autofree(controller)

	controller.handle_tap(Vector2i(0, 0))

	pass_test("no board set does not raise")
