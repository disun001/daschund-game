extends GutTest

const Cell = BoardState.Cell

func _spawn(boards: Array[BoardData]) -> GameBoard:
	var scene: PackedScene = load("res://scenes/game_board.tscn")
	var node: GameBoard = scene.instantiate()
	node.sequence = BoardSequence.new(boards)
	add_child_autofree(node)
	await wait_process_frames(1)
	return node

func _two_boards() -> Array[BoardData]:
	var a: Array[String] = ["...", "...", "..."]
	var b: Array[String] = ["....", "..W.", "....", "...A"]
	return [BoardData.new(a, 4), BoardData.new(b, 6)]

func test_default_game_starts_on_first_catalog_board_without_dog() -> void:
	var scene: PackedScene = load("res://scenes/game_board.tscn")
	var node: GameBoard = add_child_autofree(scene.instantiate())
	await wait_process_frames(1)
	assert_eq(node.board.length_cap, 8)
	assert_eq(node.board.get_cell(Vector2i(2, 2)), Cell.APPLE)
	assert_false(node.board.has_dog())

func test_next_appears_only_after_results_and_loads_fresh_next_board() -> void:
	var node := await _spawn(_two_boards())
	assert_false(node.next_button.visible)
	node.input_controller.handle_tap(Vector2i(0, 0))
	var first_board := node.board
	node.done_button.pressed.emit()
	assert_true(node.next_button.visible)
	assert_eq(node.next_button.text, "Next board")

	node.next_button.pressed.emit()
	assert_ne(node.board, first_board, "fresh BoardState instance")
	assert_eq(node.board.width, 4)
	assert_eq(node.board.length_cap, 6)
	assert_eq(node.board.get_cell(Vector2i(2, 1)), Cell.WATER)
	assert_false(node.board.has_dog())
	assert_false(node.board.is_frozen())
	assert_false(node.results_panel.visible)
	assert_false(node.next_button.visible)
	assert_true(node.hud_box.visible)
	assert_eq(node.results_panel.get_child_count(), 0, "old results cleared")

	node.input_controller.handle_tap(Vector2i(0, 0))
	assert_eq(node.board.get_cell(Vector2i(0, 0)), Cell.BODY, "first tap places the Dog")

func test_after_last_board_shows_end_of_sequence_without_looping() -> void:
	var node := await _spawn(_two_boards())
	for i in range(2):
		node.input_controller.handle_tap(Vector2i(0, 0))
		node.done_button.pressed.emit()
		if i == 1:
			assert_eq(node.next_button.text, "Finish")
		node.next_button.pressed.emit()
	assert_true(node.end_label.visible)
	assert_string_contains(node.end_label.text, "All boards complete")
	assert_false(node.next_button.visible)
	assert_false(node.results_panel.visible)
	assert_false(node.hud_box.visible)
	assert_eq(node.board.length_cap, 6, "did not loop back to board 1")

func test_empty_sequence_shows_end_of_sequence_without_crashing() -> void:
	var node := await _spawn([] as Array[BoardData])
	assert_true(node.end_label.visible)
	assert_false(node.hud_box.visible)

func test_hud_shows_dog_length_budget() -> void:
	var node := await _spawn(_two_boards())
	assert_eq(node.length_label.text, "Dog Length: 0 / 4")
	node.input_controller.handle_tap(Vector2i(0, 0))
	node.input_controller.handle_tap(Vector2i(1, 0))
	assert_eq(node.length_label.text, "Dog Length: 2 / 4")

func test_hud_has_legend_naming_every_element_with_points() -> void:
	var node := await _spawn(_two_boards())
	var text := ""
	for row in node.legend_box.get_children():
		text += (row.get_child(1) as Label).text + "\n"
	for expected in ["Water", "Apple +5", "Cherry +10", "Bee -5", "Dog"]:
		assert_string_contains(text, expected)
