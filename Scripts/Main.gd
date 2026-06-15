extends Node2D

## Main scene entry point for 2D gameplay. Handles pause input and game state.


@onready var _version_label: Label = %VersionLabel
@onready var _status_label: Label = %StatusLabel
@onready var _world_background: Sprite2D = $WorldBackground
@onready var _floor_sprite: Sprite2D = $Floor/Sprite2D
@onready var _left_wall_sprite: Sprite2D = $LeftWall/Sprite2D
@onready var _right_wall_sprite: Sprite2D = $RightWall/Sprite2D
@onready var _platform1_sprite: Sprite2D = $Platform1/Sprite2D
@onready var _platform2_sprite: Sprite2D = $Platform2/Sprite2D
@onready var _platform3_sprite: Sprite2D = $Platform3/Sprite2D
@onready var _platform4_sprite: Sprite2D = $Platform4/Sprite2D
@onready var _platform5_sprite: Sprite2D = $Platform5/Sprite2D
@onready var _platform6_sprite: Sprite2D = $Platform6/Sprite2D
@onready var _platform7_sprite: Sprite2D = $Platform7/Sprite2D
@onready var _platform8_sprite: Sprite2D = $Platform8/Sprite2D


func _ready() -> void:
	# Always process input even when paused so ESC can unpause
	process_mode = Node.PROCESS_MODE_ALWAYS
	_version_label.text = "ProjectClanker v%s" % GameServices.get_version_string()
	_status_label.text = "Running — Press Escape to pause."
	GameServices.pause_changed.connect(_on_pause_changed)
	_create_placeholder_background()


func _create_placeholder_background() -> void:
	if not _world_background:
		return
	if _world_background.texture != null:
		return
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 1))
	var tex := ImageTexture.create_from_image(img)
	_world_background.texture = tex
	
	# Create white textures for floor and walls
	var white_img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	white_img.fill(Color(1, 1, 1, 1))
	var white_tex := ImageTexture.create_from_image(white_img)
	
	if _floor_sprite and _floor_sprite.texture == null:
		_floor_sprite.texture = white_tex
	if _left_wall_sprite and _left_wall_sprite.texture == null:
		_left_wall_sprite.texture = white_tex
	if _right_wall_sprite and _right_wall_sprite.texture == null:
		_right_wall_sprite.texture = white_tex
	
	# Create cyan textures for platforms
	var cyan_img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	cyan_img.fill(Color(0.2, 0.8, 1, 1))
	var cyan_tex := ImageTexture.create_from_image(cyan_img)
	
	if _platform1_sprite and _platform1_sprite.texture == null:
		_platform1_sprite.texture = cyan_tex
	if _platform2_sprite and _platform2_sprite.texture == null:
		_platform2_sprite.texture = cyan_tex
	if _platform3_sprite and _platform3_sprite.texture == null:
		_platform3_sprite.texture = cyan_tex
	if _platform4_sprite and _platform4_sprite.texture == null:
		_platform4_sprite.texture = cyan_tex
	if _platform5_sprite and _platform5_sprite.texture == null:
		_platform5_sprite.texture = cyan_tex
	if _platform6_sprite and _platform6_sprite.texture == null:
		_platform6_sprite.texture = cyan_tex
	if _platform7_sprite and _platform7_sprite.texture == null:
		_platform7_sprite.texture = cyan_tex
	if _platform8_sprite and _platform8_sprite.texture == null:
		_platform8_sprite.texture = cyan_tex

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	GameServices.toggle_pause()
	get_viewport().set_input_as_handled()


func _on_pause_changed(is_paused: bool) -> void:
	if is_paused:
		_status_label.text = "Paused"
	else:
		_status_label.text = "Running — Press Escape to pause."
