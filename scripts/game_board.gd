class_name GameBoard
extends Node2D

## Owns the single BoardState instance for the current board attempt and
## wires the view/adapter nodes to it. InputController and BoardView never
## hold state of their own; this is the one place BoardState is created.

@export var board_width: int = 8
@export var board_height: int = 8
@export var dog_length_cap: int = 12

@onready var board_view: BoardView = $BoardView
@onready var input_controller: InputController = $InputController

var board: BoardState

func _ready() -> void:
	board = BoardState.new(board_width, board_height, dog_length_cap)
	input_controller.cell_pixel_size = board_view.cell_size()
	input_controller.set_board(board)
	input_controller.board_changed.connect(_on_board_changed)
	board_view.sync_from_board(board)

func _on_board_changed() -> void:
	board_view.sync_from_board(board)
