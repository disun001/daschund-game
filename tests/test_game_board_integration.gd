extends GutTest

const Cell = BoardState.Cell

func _spawn_open_board() -> GameBoard:
	var rows: Array[String] = []
	for i in range(8):
		rows.append("........")
	var boards: Array[BoardData] = [BoardData.new(rows, 12)]
	var scene: PackedScene = load("res://scenes/game_board.tscn")
	var node: GameBoard = scene.instantiate()
	node.sequence = BoardSequence.new(boards)
	add_child_autofree(node)
	return node

func _click_at(controller: InputController, screen_pos: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = screen_pos
	controller._unhandled_input(event)

func test_real_input_event_resolves_to_the_correct_cell() -> void:
	var board_node := _spawn_open_board()
	await wait_process_frames(1)

	var cell_px: int = board_node.board_view.cell_size()

	# Place at cell (2,2), extend to (3,3), extend to (4,4) -> length 3.
	_click_at(board_node.input_controller, Vector2(2 * cell_px + 4, 2 * cell_px + 4))
	_click_at(board_node.input_controller, Vector2(3 * cell_px + 4, 3 * cell_px + 4))
	_click_at(board_node.input_controller, Vector2(4 * cell_px + 4, 4 * cell_px + 4))

	assert_eq(board_node.board.get_cell(Vector2i(4, 4)), Cell.BODY, "third cell placed")
	assert_eq(board_node.board.length_used, 3)

	# Tap the middle cell (3,3) -> removes only that cell; the Dog splits.
	_click_at(board_node.input_controller, Vector2(3 * cell_px + 4, 3 * cell_px + 4))

	assert_eq(board_node.board.length_used, 2)
	assert_eq(board_node.board.get_cell(Vector2i(3, 3)), Cell.EMPTY, "the tapped cell should render empty")
	assert_eq(board_node.board.get_cell(Vector2i(4, 4)), Cell.BODY, "cells past it are kept")
	assert_false(board_node.board.can_submit(), "split Dog cannot be submitted")

func test_input_controller_adopts_board_view_cell_size() -> void:
	var board_node := _spawn_open_board()
	await wait_process_frames(1)

	assert_eq(board_node.input_controller.cell_pixel_size, board_node.board_view.cell_size())


func test_hud_shows_live_score() -> void:
	var board_node := _spawn_open_board()
	await wait_process_frames(1)
	assert_eq(board_node.score_label.text, "Score: 0")

func test_hud_score_updates_after_edit_that_encloses() -> void:
	var board_node := _spawn_open_board()
	await wait_process_frames(1)
	# A diagonal diamond around (2,2) seals that cell (no squeezing).
	for p in [Vector2i(2, 1), Vector2i(3, 2), Vector2i(2, 3), Vector2i(1, 2)]:
		var px: int = board_node.board_view.cell_size()
		_click_at(board_node.input_controller, Vector2(p.x * px + 4, p.y * px + 4))
	assert_eq(board_node.board.length_used, 4)
	assert_eq(board_node.score_label.text, "Score: 1")

func test_done_hidden_until_dog_then_shows_results_and_freezes() -> void:
	var board_node := _spawn_open_board()
	await wait_process_frames(1)

	assert_false(board_node.done_button.visible, "no Dog yet")
	board_node.input_controller.handle_tap(Vector2i(2, 2))
	board_node.input_controller.handle_tap(Vector2i(3, 2))
	assert_true(board_node.done_button.visible)
	assert_false(board_node.done_button.disabled)

	board_node.input_controller.handle_tap(Vector2i(4, 2))
	board_node.input_controller.handle_tap(Vector2i(3, 2))
	assert_true(board_node.done_button.disabled, "split Dog")
	assert_true(board_node.split_warning.visible)
	board_node.input_controller.handle_tap(Vector2i(3, 2))
	board_node.input_controller.handle_tap(Vector2i(4, 2))

	board_node.done_button.pressed.emit()
	assert_true(board_node.board.is_frozen())
	assert_true(board_node.results_panel.visible)
	assert_false(board_node.hud_box.visible)

	var length_before := board_node.board.length_used
	board_node.input_controller.handle_tap(Vector2i(4, 2))
	assert_eq(board_node.board.length_used, length_before)

func test_results_text_shows_total_and_enclosure_breakdown() -> void:
	var board_node := _spawn_open_board()
	await wait_process_frames(1)
	for p in [Vector2i(2, 1), Vector2i(3, 2), Vector2i(2, 3), Vector2i(1, 2)]:
		board_node.input_controller.handle_tap(p)
	board_node.done_button.pressed.emit()

	var report := board_node.board.final_report
	var lines: Array[String] = []
	for child in board_node.results_panel.get_children():
		lines.append((child as Label).text)
	assert_eq(lines.size(), report.enclosures.size() + 1)
	assert_string_contains(lines[0], "Total: %d" % report.total)
	assert_string_contains(lines[1], "Enclosure 1")
	assert_string_contains(lines[1], "= %d" % report.enclosures[0].score)
	assert_string_contains(lines[1], "Empty")
