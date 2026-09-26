extends GutTest

func _boards(n: int) -> Array[BoardData]:
	var out: Array[BoardData] = []
	for i in range(n):
		out.append(BoardData.new(["."], i + 1))
	return out

func test_plays_boards_in_given_order_then_finishes_without_looping() -> void:
	var seq := BoardSequence.new(_boards(3))
	assert_eq(seq.current().dog_length_cap, 1)
	assert_false(seq.is_finished())

	seq.advance()
	assert_eq(seq.current().dog_length_cap, 2)
	seq.advance()
	assert_eq(seq.current().dog_length_cap, 3)
	assert_false(seq.is_finished())

	seq.advance()
	assert_true(seq.is_finished())
	assert_null(seq.current())

	seq.advance()
	assert_true(seq.is_finished(), "stays finished, no loop back")

func test_default_sequence_is_the_catalog_in_order() -> void:
	var seq := BoardSequence.new()
	assert_eq(seq.current().dog_length_cap, 8)
