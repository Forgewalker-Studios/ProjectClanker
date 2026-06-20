class_name LevelLayoutConfig
## Single source of truth for Level1 paint bounds and aspect ratio.

## Level aspect width units.
const ASPECT_WIDTH: int = 10

## Level aspect height units.
const ASPECT_HEIGHT: int = 3

## Tile and grid cell size in pixels.
const CELL_SIZE: int = 64

## Grid height in cells (unchanged from the original level paint layout).
const GRID_HEIGHT_CELLS: int = 45

## Grid width in cells derived from the 10:3 aspect ratio.
const GRID_WIDTH_CELLS: int = (GRID_HEIGHT_CELLS / ASPECT_HEIGHT) * ASPECT_WIDTH

## Level width in pixels.
const LEVEL_WIDTH_PIXELS: int = GRID_WIDTH_CELLS * CELL_SIZE

## Level height in pixels.
const LEVEL_HEIGHT_PIXELS: int = GRID_HEIGHT_CELLS * CELL_SIZE
