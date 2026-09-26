extends GutTest

const Cell = BoardState.Cell

func _click_at(controller: InputController, screen_pos: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = screen_pos
	controller._unhandled_input(event)

func test_real_input_event_resolves_to_the_correct_cell() -> void:
	var scene: PackedScene = load("res://scenes/game_board.tscn")
	var board_node: GameBoard = add_child_autofree(scene.instantiate())
	await wait_process_frames(1)

	var cell_px: int = board_node.board_view.cell_size()

	# Place at cell (2,2), extend to (3,3), extend to (4,4) -> length 3.
	_click_at(board_node.input_controller, Vector2(2 * cell_px + 4, 2 * cell_px + 4))
	_click_at(board_node.input_controller, Vector2(3 * cell_px + 4, 3 * cell_px + 4))
	_click_at(board_node.input_controller, Vector2(4 * cell_px + 4, 4 * cell_px + 4))

	assert_eq(board_node.board.head(), Vector2i(4, 4), "head after two extends")
	assert_eq(board_node.board.length_used, 3)

	# Tap the SECOND cell placed (3,3) -> should truncate to it, dropping (4,4).
	_click_at(board_node.input_controller, Vector2(3 * cell_px + 4, 3 * cell_px + 4))

	assert_eq(board_node.board.head(), Vector2i(3, 3), "truncating the middle cell should move head there")
	assert_eq(board_node.board.length_used, 2)
	assert_eq(board_node.board.get_cell(Vector2i(4, 4)), Cell.EMPTY, "the dropped cell should render empty")

func test_input_controller_adopts_board_view_cell_size() -> void:
	var scene: PackedScene = load("res://scenes/game_board.tscn")
	var board_node: GameBoard = add_child_autofree(scene.instantiate())
	await wait_process_frames(1)

	assert_eq(board_node.input_controller.cell_pixel_size, board_node.board_view.cell_size())

