class_name InputController
extends Node

## Converts a tap into a grid coordinate and forwards it to BoardState.
## Holds no game-state of its own.

@export var board_view_path: NodePath
@export var cell_pixel_size: int = 16

var _board: BoardState
var _board_view: BoardView

signal board_changed

func _ready() -> void:
	if not board_view_path.is_empty():
		_board_view = get_node(board_view_path)

func set_board(board: BoardState) -> void:
	_board = board

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if _board == null:
		return

	var local_pos: Vector2 = event.position
	if _board_view != null:
		local_pos = _board_view.to_local(event.position)
	handle_tap_at_local_position(local_pos)

func handle_tap_at_local_position(local_pos: Vector2) -> void:
	var cell := Vector2i(floori(local_pos.x / cell_pixel_size), floori(local_pos.y / cell_pixel_size))
	handle_tap(cell)

func handle_tap(cell: Vector2i) -> void:
	if _board == null:
		return
	_board.resolve_tap(cell)
	board_changed.emit()
