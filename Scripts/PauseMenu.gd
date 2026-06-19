extends CanvasLayer

## In-game pause overlay with resume, restart, and quit-to-menu actions.

@onready var _dim_overlay: ColorRect = $DimOverlay
@onready var _menu_panel: PanelContainer = $MenuPanel
@onready var _resume_button: Button = %ResumeButton
@onready var _restart_button: Button = %RestartButton
@onready var _quit_to_menu_button: Button = %QuitToMenuButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_dim_overlay.color = Color(0.0, 0.0, 0.0, 0.55)
	_resume_button.pressed.connect(_on_resume_pressed)
	_restart_button.pressed.connect(_on_restart_pressed)
	_quit_to_menu_button.pressed.connect(_on_quit_to_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	_toggle_pause()
	get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	var should_pause: bool = not get_tree().paused
	get_tree().paused = should_pause
	GameServices.set_paused(should_pause)
	visible = should_pause


func _on_resume_pressed() -> void:
	_toggle_pause()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameServices.set_paused(false)
	visible = false
	get_tree().reload_current_scene()


func _on_quit_to_menu_pressed() -> void:
	get_tree().paused = false
	GameServices.set_paused(false)
	visible = false
	SceneTransition.request_scene_change("res://Scenes/UI/MainMenu.tscn")
