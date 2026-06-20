extends SceneTree
## Headless utility that builds the LevelPaint TileSet from the environment atlas.


func _init() -> void:
	var tile_set: TileSet = TileSet.new()
	var atlas: TileSetAtlasSource = TileSetAtlasSource.new()
	var texture: Texture2D = load("res://Art/Environment/LevelPaintAtlas.png")
	if texture == null:
		push_error("LevelPaint atlas texture failed to load after import.")
		quit(1)
		return

	atlas.texture = texture
	atlas.texture_region_size = Vector2i(64, 64)
	var columns: int = texture.get_width() / 64
	var rows: int = texture.get_height() / 64

	for y in range(rows):
		for x in range(columns):
			atlas.create_tile(Vector2i(x, y))

	tile_set.add_source(atlas, 0)
	var save_error: Error = ResourceSaver.save(tile_set, "res://Resources/TileSets/LevelPaintTileSet.tres")
	if save_error != OK:
		push_error("Failed to save LevelPaintTileSet.tres: %s" % str(save_error))
		quit(1)
		return

	print("Saved LevelPaintTileSet.tres with %d tiles." % (columns * rows))
	quit()
