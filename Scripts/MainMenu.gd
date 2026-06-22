extends Control

## Main menu: start, quit, settings, and controls reference.

const GAMEPLAY_SCENE_PATH: String = "res://Scenes/Hub/DoorHub.tscn"

@onready var _start_button: Button = %StartButton
@onready var _settings_button: Button = %SettingsButton
@onready var _controls_button: Button = %ControlsButton
@onready var _credits_button: Button = %CreditsButton
@onready var _quit_button: Button = %QuitButton
@onready var _menu_column: VBoxContainer = %CenterColumn
@onready var _modal_scrim: ColorRect = %ModalScrim
@onready var _settings_panel: PanelContainer = %SettingsPanel
@onready var _controls_panel: PanelContainer = %ControlsPanel
@onready var _credits_panel: PanelContainer = %CreditsPanel
@onready var _music_slider: HSlider = %MusicSlider
@onready var _sfx_slider: HSlider = %SfxSlider
@onready var _mute_button: Button = %MuteButton
@onready var _settings_back_button: Button = %SettingsBackButton
@onready var _controls_back_button: Button = %ControlsBackButton
@onready var _credits_back_button: Button = %CreditsBackButton

var _audio_mix: AudioMixControlSystem


func _ready() -> void:
	AudioDirector.set_music_context(AudioDirector.MusicContext.MENU)
	_wire_buttons()
	_setup_audio_mix()
	_hide_overlay_panels()
	ClankerSettings.settings_changed.connect(_sync_sliders_from_settings)
	_start_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and _is_overlay_visible():
		_hide_overlay_panels()
		get_viewport().set_input_as_handled()


func _wire_buttons() -> void:
	_start_button.pressed.connect(_on_start_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_controls_button.pressed.connect(_on_controls_pressed)
	_credits_button.pressed.connect(_on_credits_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_settings_back_button.pressed.connect(_hide_overlay_panels)
	_controls_back_button.pressed.connect(_hide_overlay_panels)
	_credits_back_button.pressed.connect(_hide_overlay_panels)


func _setup_audio_mix() -> void:
	_audio_mix = AudioMixControlSystem.new()
	_audio_mix.name = "AudioMixControl"
	add_child(_audio_mix)
	_audio_mix.setup(_music_slider, _sfx_slider, _mute_button)
	_sync_sliders_from_settings()
	_music_slider.value_changed.connect(_on_audio_slider_changed)
	_sfx_slider.value_changed.connect(_on_audio_slider_changed)
	_mute_button.pressed.connect(_on_mute_button_pressed)


func _sync_sliders_from_settings() -> void:
	_music_slider.value = float(
		ClankerSettings.get_value(
			ClankerSettings.CATEGORY_AUDIO,
			ClankerSettings.KEY_MUSIC_VOLUME,
			ClankerSettings.DEFAULT_MUSIC_VOLUME
		)
	)
	_sfx_slider.value = float(
		ClankerSettings.get_value(
			ClankerSettings.CATEGORY_AUDIO,
			ClankerSettings.KEY_SFX_VOLUME,
			ClankerSettings.DEFAULT_SFX_VOLUME
		)
	)


func _on_start_pressed() -> void:
	SceneTransition.request_scene_change(GAMEPLAY_SCENE_PATH)


func _on_settings_pressed() -> void:
	_show_modal(_settings_panel)
	_settings_panel.visible = true
	_controls_panel.visible = false
	_credits_panel.visible = false
	_settings_back_button.grab_focus()


func _on_controls_pressed() -> void:
	_show_modal(_controls_panel)
	_controls_panel.visible = true
	_settings_panel.visible = false
	_credits_panel.visible = false
	_controls_back_button.grab_focus()


func _on_credits_pressed() -> void:
	_show_modal(_credits_panel)
	_credits_panel.visible = true
	_settings_panel.visible = false
	_controls_panel.visible = false
	_credits_back_button.grab_focus()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _hide_overlay_panels() -> void:
	_settings_panel.visible = false
	_controls_panel.visible = false
	_credits_panel.visible = false
	_modal_scrim.visible = false
	_menu_column.modulate = Color.WHITE
	_start_button.grab_focus()


func _show_modal(panel: PanelContainer) -> void:
	_modal_scrim.visible = true
	_menu_column.modulate = Color(0.45, 0.5, 0.52, 1.0)
	panel.visible = true


func _is_overlay_visible() -> bool:
	return _settings_panel.visible or _controls_panel.visible or _credits_panel.visible


func _on_audio_slider_changed(_value: float) -> void:
	ClankerSettings.set_value(
		ClankerSettings.CATEGORY_AUDIO,
		ClankerSettings.KEY_MUSIC_VOLUME,
		_music_slider.value
	)
	ClankerSettings.set_value(
		ClankerSettings.CATEGORY_AUDIO,
		ClankerSettings.KEY_SFX_VOLUME,
		_sfx_slider.value
	)


func _on_mute_button_pressed() -> void:
	var master_index: int = AudioServer.get_bus_index(&"Master")
	if master_index < 0:
		return
	var muted_now: bool = AudioServer.is_bus_mute(master_index)
	ClankerSettings.set_value(
		ClankerSettings.CATEGORY_AUDIO,
		ClankerSettings.KEY_MASTER_MUTED,
		muted_now
	)
