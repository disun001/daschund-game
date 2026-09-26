class_name BoardState
extends RefCounted

enum Cell { EMPTY, BODY, WATER, APPLE, CHERRY, BEE }

enum Action { PLACE, EXTEND, REMOVE, INVALID }

var width: int
var height: int
var length_cap: int
var length_used: int = 0

var _cells: Array

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
	return length_used > 0

func body_cells() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(height):
		for x in range(width):
			if _cells[y][x] == Cell.BODY:
				out.append(Vector2i(x, y))
	return out

func _is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var dx: int = abs(a.x - b.x)
	var dy: int = abs(a.y - b.y)
	return dx <= 1 and dy <= 1 and dx + dy > 0

func _body_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var n := Vector2i(pos.x + dx, pos.y + dy)
			if is_in_bounds(n) and get_cell(n) == Cell.BODY:
				out.append(n)
	return out

## An End is a Body Cell with at most one adjacent Body Cell.
func is_end(pos: Vector2i) -> bool:
	return is_in_bounds(pos) and get_cell(pos) == Cell.BODY and _body_neighbors(pos).size() <= 1

func _touches_end(pos: Vector2i) -> bool:
	for n in _body_neighbors(pos):
		if is_end(n):
			return true
	return false

## True when the Body forms exactly one Segment (8-directional adjacency).
## An empty Dog is not connected.
func is_dog_connected() -> bool:
	var cells := body_cells()
	if cells.is_empty():
		return false
	var seen := {cells[0]: true}
	var stack: Array[Vector2i] = [cells[0]]
	while not stack.is_empty():
		var cur: Vector2i = stack.pop_back()
		for n in _body_neighbors(cur):
			if not seen.has(n):
				seen[n] = true
				stack.append(n)
	return seen.size() == cells.size()

## Done is only allowed for a Connected Dog.
func can_submit() -> bool:
	return is_dog_connected()

## Resolves a tap on the given cell against the current board state, applying
## the single move it represents (place / extend / remove) or rejecting it
## as a no-op. Returns the Action taken.
func resolve_tap(pos: Vector2i) -> Action:
	if not is_in_bounds(pos):
		return Action.INVALID

	var cell := get_cell(pos)
	if cell == Cell.BODY:
		_set_cell(pos, Cell.EMPTY)
		length_used -= 1
		return Action.REMOVE

	if cell != Cell.EMPTY or length_used >= length_cap:
		return Action.INVALID

	if not has_dog():
		_add_body(pos)
		return Action.PLACE

	if _touches_end(pos):
		_add_body(pos)
		return Action.EXTEND

	return Action.INVALID

func _add_body(pos: Vector2i) -> void:
	_set_cell(pos, Cell.BODY)
	length_used += 1
