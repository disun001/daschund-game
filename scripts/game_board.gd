class_name GameBoard
extends Node2D

## Owns the single BoardState instance for the current board attempt and
## wires the view/adapter nodes to it. InputController and BoardView never
## hold state of their own; this is the one place BoardState is created.

@onready var board_view: BoardView = $BoardView
@onready var input_controller: InputController = $InputController

const HUD_MARGIN := 8
const HUD_LINE_HEIGHT := 28

## Fixed play order. Tests may assign one before the node enters the tree.
var sequence: BoardSequence
var board: BoardState
var split_warning: Label
var done_button: Button
var score_label: Label
var length_label: Label
var legend_box: VBoxContainer
var hud_box: VBoxContainer
var results_panel: VBoxContainer
var next_button: Button
var end_label: Label

func _ready() -> void:
	if sequence == null:
		sequence = BoardSequence.new()
	input_controller.cell_pixel_size = board_view.cell_size()
	input_controller.board_changed.connect(_on_board_changed)
	_build_hud()
	if sequence.is_finished():
		_show_end_of_sequence()
	else:
		_start_board()

## Instantiates a fresh BoardState from the sequence's current board data.
func _start_board() -> void:
	board = sequence.current().make_state()
	input_controller.set_board(board)
	var origin := Vector2(HUD_MARGIN, board.height * board_view.cell_size() + HUD_MARGIN)
	hud_box.position = origin
	results_panel.position = origin
	end_label.position = origin
	for child in results_panel.get_children():
		results_panel.remove_child(child)
		child.queue_free()
	results_panel.visible = false
	next_button.visible = false
	hud_box.visible = true
	_refresh()

func _on_next_pressed() -> void:
	sequence.advance()
	if sequence.is_finished():
		_show_end_of_sequence()
	else:
		_start_board()

func _show_end_of_sequence() -> void:
	results_panel.visible = false
	next_button.visible = false
	hud_box.visible = false
	end_label.visible = true

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var box := VBoxContainer.new()
	hud_box = box
	layer.add_child(box)
	score_label = Label.new()
	box.add_child(score_label)
	length_label = Label.new()
	box.add_child(length_label)
	_build_legend(box)
	split_warning = Label.new()
	split_warning.text = "Dog is split"
	box.add_child(split_warning)
	done_button = Button.new()
	done_button.text = "Done"
	done_button.pressed.connect(_on_done_pressed)
	box.add_child(done_button)
	results_panel = VBoxContainer.new()
	results_panel.visible = false
	layer.add_child(results_panel)
	next_button = Button.new()
	next_button.text = "Next board"
	next_button.visible = false
	next_button.pressed.connect(_on_next_pressed)
	layer.add_child(next_button)
	end_label = Label.new()
	end_label.text = "All boards complete"
	end_label.visible = false
	layer.add_child(end_label)

## One row per element: colour swatch + name and point value.
func _build_legend(parent: Control) -> void:
	legend_box = VBoxContainer.new()
	parent.add_child(legend_box)
	var entries := [
		[BoardState.Cell.BODY, "Dog"],
		[BoardState.Cell.WATER, "Water (wall)"],
		[BoardState.Cell.APPLE, "Apple +%d" % BoardState.POINTS_APPLE],
		[BoardState.Cell.CHERRY, "Cherry +%d" % BoardState.POINTS_CHERRY],
		[BoardState.Cell.BEE, "Bee %d" % BoardState.POINTS_BEE],
	]
	for entry in entries:
		var row := HBoxContainer.new()
		var swatch := ColorRect.new()
		swatch.color = BoardView.CELL_COLORS[entry[0]]
		swatch.custom_minimum_size = Vector2(16, 16)
		row.add_child(swatch)
		var label := Label.new()
		label.text = entry[1]
		row.add_child(label)
		legend_box.add_child(row)

func _on_done_pressed() -> void:
	if board.submit():
		_show_results()

## Renders the frozen snapshot (board.final_report), never a live recompute.
func _show_results() -> void:
	hud_box.visible = false
	board_view.sync_from_board(board)
	var report := board.final_report
	var title := Label.new()
	title.text = "Results — Total: %d" % report.total
	results_panel.add_child(title)
	for i in range(report.enclosures.size()):
		var enclosure := report.enclosures[i]
		var line := Label.new()
		line.text = "Enclosure %d: %s = %d" % [i + 1, _tally_text(enclosure), enclosure.score]
		results_panel.add_child(line)
	results_panel.visible = true
	next_button.position = results_panel.position + Vector2(0, (report.enclosures.size() + 1) * HUD_LINE_HEIGHT)
	next_button.text = "Finish" if sequence.is_last() else "Next board"
	next_button.visible = true

func _tally_text(enclosure: BoardState.Enclosure) -> String:
	var parts: Array[String] = []
	for cell in enclosure.tally:
		parts.append("%d %s" % [enclosure.tally[cell], BoardState.Cell.find_key(cell).capitalize()])
	return ", ".join(parts)

func _on_board_changed() -> void:
	_refresh()

func _refresh() -> void:
	board_view.sync_from_board(board)
	split_warning.visible = board.has_dog() and not board.is_dog_connected()
	done_button.visible = board.has_dog()
	done_button.disabled = not board.can_submit()
	score_label.text = "Score: %d" % board.score_report().total
	length_label.text = "Dog Length: %d / %d" % [board.length_used, board.length_cap]
