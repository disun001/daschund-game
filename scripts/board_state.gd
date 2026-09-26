class_name BoardState
extends RefCounted

enum Cell { EMPTY, BODY, WATER, APPLE, CHERRY, BEE }

enum Action { PLACE, EXTEND, TRUNCATE, INVALID }

var width: int
var height: int
var length_cap: int
var length_used: int = 0

var _cells: Array
var _body_path: Array[Vector2i] = []

func _init(p_width: int, p_height: int, p_length_cap: int, initial_cells: Array = []) -> void:
	width = p_width
	height = p_height
	length_cap = p_length_cap
	if initial_cells.is_empty():
		_cells = _make_empty_grid()
	else:
		_cells = initial_cells

func _make_empty_grid() -> Array:
	var grid := []
	for y in range(height):
		var row := []
		row.resize(width)
		row.fill(Cell.EMPTY)
		grid.append(row)
	return grid

func get_cell(pos: Vector2i) -> Cell:
	return _cells[pos.y][pos.x]

func _set_cell(pos: Vector2i, value: Cell) -> void:
	_cells[pos.y][pos.x] = value

func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height

func has_dog() -> bool:
	return not _body_path.is_empty()

func head() -> Vector2i:
	return _body_path[-1]

func tail() -> Vector2i:
	return _body_path[0]

func body_path() -> Array[Vector2i]:
	return _body_path.duplicate()

func _is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var dx: int = abs(a.x - b.x)
	var dy: int = abs(a.y - b.y)
	return dx <= 1 and dy <= 1 and dx + dy > 0

func _index_in_body(pos: Vector2i) -> int:
	for i in range(_body_path.size()):
		if _body_path[i] == pos:
			return i
	return -1

## Resolves a tap on the given cell against the current board state, applying
## the single move it represents (place / extend / truncate) or rejecting it
## as a no-op. Returns the Action taken.
func resolve_tap(pos: Vector2i) -> Action:
	if not is_in_bounds(pos):
		return Action.INVALID

	if not has_dog():
		if get_cell(pos) == Cell.EMPTY:
			_place(pos)
			return Action.PLACE
		return Action.INVALID

	var body_index := _index_in_body(pos)
	if body_index != -1:
		_truncate_to(body_index)
		return Action.TRUNCATE

	if get_cell(pos) == Cell.EMPTY and _is_adjacent(pos, head()) and length_used < length_cap:
		_extend(pos)
		return Action.EXTEND

	return Action.INVALID

func _place(pos: Vector2i) -> void:
	_body_path = [pos]
	_set_cell(pos, Cell.BODY)
	length_used = 1

func _extend(pos: Vector2i) -> void:
	_body_path.append(pos)
	_set_cell(pos, Cell.BODY)
	length_used += 1

func _truncate_to(index: int) -> void:
	for i in range(index + 1, _body_path.size()):
		_set_cell(_body_path[i], Cell.EMPTY)
	_body_path = _body_path.slice(0, index + 1)
	length_used = _body_path.size()
