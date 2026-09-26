class_name BoardView
extends TileMapLayer

const CELL_PIXEL_SIZE := 16

const CELL_ORDER: Array[BoardState.Cell] = [
	BoardState.Cell.EMPTY,
	BoardState.Cell.BODY,
	BoardState.Cell.WATER,
	BoardState.Cell.APPLE,
	BoardState.Cell.CHERRY,
	BoardState.Cell.BEE,
]

const CELL_COLORS := {
	BoardState.Cell.EMPTY: Color(0.85, 0.85, 0.8),
	BoardState.Cell.BODY: Color(0.55, 0.35, 0.15),
	BoardState.Cell.WATER: Color(0.2, 0.5, 0.9),
	BoardState.Cell.APPLE: Color(0.85, 0.1, 0.1),
	BoardState.Cell.CHERRY: Color(0.8, 0.1, 0.4),
	BoardState.Cell.BEE: Color(0.95, 0.85, 0.1),
}

func _ready() -> void:
	if tile_set == null:
		tile_set = _build_tile_set()

func _build_tile_set() -> TileSet:
	var image := Image.create(CELL_PIXEL_SIZE * CELL_ORDER.size(), CELL_PIXEL_SIZE, false, Image.FORMAT_RGBA8)
	for i in range(CELL_ORDER.size()):
		image.fill_rect(Rect2i(i * CELL_PIXEL_SIZE, 0, CELL_PIXEL_SIZE, CELL_PIXEL_SIZE), CELL_COLORS[CELL_ORDER[i]])

	var atlas_source := TileSetAtlasSource.new()
	atlas_source.texture = ImageTexture.create_from_image(image)
	atlas_source.texture_region_size = Vector2i(CELL_PIXEL_SIZE, CELL_PIXEL_SIZE)
	for i in range(CELL_ORDER.size()):
		atlas_source.create_tile(Vector2i(i, 0))

	var new_tile_set := TileSet.new()
	new_tile_set.tile_size = Vector2i(CELL_PIXEL_SIZE, CELL_PIXEL_SIZE)
	new_tile_set.add_source(atlas_source, 0)
	return new_tile_set

## Re-renders every Cell from the given BoardState's array. BoardView holds
## no game-state of its own — it is a pure view over BoardState.
func sync_from_board(board: BoardState) -> void:
	clear()
	for y in range(board.height):
		for x in range(board.width):
			var pos := Vector2i(x, y)
			var atlas_x := CELL_ORDER.find(board.get_cell(pos))
			set_cell(pos, 0, Vector2i(atlas_x, 0))

func cell_size() -> int:
	return CELL_PIXEL_SIZE
