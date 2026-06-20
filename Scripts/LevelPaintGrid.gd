extends Node2D
## Draws a visible 64px grid for level sprite painting in the editor and at runtime.

## Width of the painted grid in cells.
@export var grid_width_cells: int = LevelLayoutConfig.GRID_WIDTH_CELLS

## Height of the painted grid in cells.
@export var grid_height_cells: int = LevelLayoutConfig.GRID_HEIGHT_CELLS

## Pixel size of each grid cell.
@export var cell_size: int = LevelLayoutConfig.CELL_SIZE

## Grid line color.
@export var grid_color: Color = Color(1.0, 1.0, 1.0, 0.12)

## Origin offset for the grid in pixels.
@export var grid_origin: Vector2 = Vector2.ZERO


func _draw() -> void:
	var width_pixels: float = float(grid_width_cells * cell_size)
	var height_pixels: float = float(grid_height_cells * cell_size)
	var origin: Vector2 = grid_origin

	for x in range(grid_width_cells + 1):
		var x_pos: float = origin.x + float(x * cell_size)
		draw_line(
			Vector2(x_pos, origin.y),
			Vector2(x_pos, origin.y + height_pixels),
			grid_color,
			1.0
		)

	for y in range(grid_height_cells + 1):
		var y_pos: float = origin.y + float(y * cell_size)
		draw_line(
			Vector2(origin.x, y_pos),
			Vector2(origin.x + width_pixels, y_pos),
			grid_color,
			1.0
		)
