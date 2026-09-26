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

	assert_eq(board_node.board.get_cell(Vector2i(4, 4)), Cell.BODY, "third cell placed")
	assert_eq(board_node.board.length_used, 3)

	# Tap the middle cell (3,3) -> removes only that cell; the Dog splits.
	_click_at(board_node.input_controller, Vector2(3 * cell_px + 4, 3 * cell_px + 4))

	assert_eq(board_node.board.length_used, 2)
	assert_eq(board_node.board.get_cell(Vector2i(3, 3)), Cell.EMPTY, "the tapped cell should render empty")
	assert_eq(board_node.board.get_cell(Vector2i(4, 4)), Cell.BODY, "cells past it are kept")
	assert_false(board_node.board.can_submit(), "split Dog cannot be submitted")

func test_input_controller_adopts_board_view_cell_size() -> void:
	var scene: PackedScene = load("res://scenes/game_board.tscn")
	var board_node: GameBoard = add_child_autofree(scene.instantiate())
	await wait_process_frames(1)

	assert_eq(board_node.input_controller.cell_pixel_size, board_node.board_view.cell_size())


func test_hud_shows_live_score() -> void:
	var scene: PackedScene = load("res://scenes/game_board.tscn")
	var board_node: GameBoard = add_child_autofree(scene.instantiate())
	await wait_process_frames(1)
	assert_eq(board_node.score_label.text, "Score: 0")

func test_hud_score_updates_after_edit_that_encloses() -> void:
	var scene: PackedScene = load("res://scenes/game_board.tscn")
	var board_node: GameBoard = add_child_autofree(scene.instantiate())
	await wait_process_frames(1)
	# A diagonal diamond around (2,2) seals that cell (no squeezing).
	for p in [Vector2i(2, 1), Vector2i(3, 2), Vector2i(2, 3), Vector2i(1, 2)]:
		var px: int = board_node.board_view.cell_size()
		_click_at(board_node.input_controller, Vector2(p.x * px + 4, p.y * px + 4))
	assert_eq(board_node.board.length_used, 4)
	assert_eq(board_node.score_label.text, "Score: 1")
