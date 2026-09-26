class_name BoardSequence
extends RefCounted

## Walks a fixed, ordered list of boards. Never shuffles or loops: after the
## last board is advanced past, is_finished() stays true.

var _boards: Array[BoardData]
var _index: int = 0

func _init(boards: Array[BoardData] = BoardCatalog.all()) -> void:
	_boards = boards

## The board to play now, or null once the sequence is finished.
func current() -> BoardData:
	return null if is_finished() else _boards[_index]

func advance() -> void:
	if not is_finished():
		_index += 1

func is_finished() -> bool:
	return _index >= _boards.size()

func is_last() -> bool:
	return _index == _boards.size() - 1
