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
var split_warning: Label
var done_button: Button
var score_label: Label

func _ready() -> void:
	board = BoardState.new(board_width, board_height, dog_length_cap)
	input_controller.cell_pixel_size = board_view.cell_size()
	input_controller.set_board(board)
	input_controller.board_changed.connect(_on_board_changed)
	_build_hud()
	_refresh()

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var box := VBoxContainer.new()
	box.position = Vector2(8, board_height * board_view.cell_size() + 8)
	layer.add_child(box)
	score_label = Label.new()
	box.add_child(score_label)
	split_warning = Label.new()
	split_warning.text = "Dog is split"
	box.add_child(split_warning)
	done_button = Button.new()
	done_button.text = "Done"
	box.add_child(done_button)

func _on_board_changed() -> void:
	_refresh()

func _refresh() -> void:
	board_view.sync_from_board(board)
	split_warning.visible = board.has_dog() and not board.is_dog_connected()
	done_button.disabled = not board.can_submit()
	score_label.text = "Score: %d" % board.score_report().total
