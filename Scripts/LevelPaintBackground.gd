extends ParallaxBackground
## Vertical gradient sky plus slow-scrolling midground parallax for Level1.

## Industrial midground silhouette texture tiled across the level width.
@export var midground_texture: Texture2D

## Camera scroll factor for the midground (lower values scroll slower).
@export var midground_scroll_scale: Vector2 = Vector2(0.35, 0.0)

## Top color of the vertical gradient backdrop.
@export var gradient_top_color: Color = Color(0.09, 0.09, 0.1, 1.0)

## Bottom color of the vertical gradient backdrop.
@export var gradient_bottom_color: Color = Color(0.33, 0.33, 0.35, 1.0)


func _ready() -> void:
	layer = -100
	_build_gradient_layer()
	_build_midground_layer()


func _build_gradient_layer() -> void:
	var layer_node: ParallaxLayer = ParallaxLayer.new()
	layer_node.name = "GradientLayer"
	layer_node.motion_scale = Vector2(0.0, 1.0)
	add_child(layer_node)

	var gradient: Gradient = Gradient.new()
	gradient.add_point(0.0, gradient_top_color)
	gradient.add_point(1.0, gradient_bottom_color)

	var gradient_texture: GradientTexture2D = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.width = LevelLayoutConfig.LEVEL_WIDTH_PIXELS
	gradient_texture.height = LevelLayoutConfig.LEVEL_HEIGHT_PIXELS
	gradient_texture.fill_from = Vector2(0.5, 0.0)
	gradient_texture.fill_to = Vector2(0.5, 1.0)

	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "Gradient"
	sprite.texture = gradient_texture
	sprite.centered = false
	sprite.position = Vector2.ZERO
	layer_node.add_child(sprite)


func _build_midground_layer() -> void:
	if midground_texture == null:
		push_error("LevelPaintBackground requires midground_texture.")
		return

	var layer_node: ParallaxLayer = ParallaxLayer.new()
	layer_node.name = "MidgroundLayer"
	layer_node.motion_scale = Vector2(midground_scroll_scale.x, 1.0)

	var tex_size: Vector2 = midground_texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		push_error("LevelPaintBackground midground texture size is invalid.")
		return

	var height_scale: float = float(LevelLayoutConfig.LEVEL_HEIGHT_PIXELS) / tex_size.y
	var scaled_width: float = tex_size.x * height_scale
	var tile_count: int = int(ceil(float(LevelLayoutConfig.LEVEL_WIDTH_PIXELS) / scaled_width)) + 1

	for tile_index in range(tile_count):
		var sprite: Sprite2D = Sprite2D.new()
		sprite.name = "Midground_%d" % tile_index
		sprite.texture = midground_texture
		sprite.centered = false
		sprite.position = Vector2(float(tile_index) * scaled_width, 0.0)
		sprite.scale = Vector2(height_scale, height_scale)
		layer_node.add_child(sprite)

	layer_node.motion_mirroring = Vector2(scaled_width, 0.0)
	add_child(layer_node)
