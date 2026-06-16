class_name AudioMixControlSystem
extends Control

## Reusable audio mix UI glue.
## Attach to a UI root that contains:
## - music slider
## - sfx slider
## - mute-all button
## Then call [method setup] with those nodes.
## Use this as menu glue for a simple music/SFX/master mute panel.
## This script directly writes to [AudioServer] buses.
## Caller must provide valid [Range]/[Button] nodes and valid bus names.
## This script does not persist settings; save/load belongs in separate glue.

const DEFAULT_MIN: float = 0.0
const DEFAULT_MAX: float = 1.0
const DEFAULT_STEP: float = 0.02

var _music_slider: Range
var _sfx_slider: Range
var _mute_button: Button
var _music_bus: StringName = &"Music"
var _sfx_bus: StringName = &"SFX"
var _master_bus: StringName = &"Master"
var _master_muted: bool = false
var _mute_label: String = "Mute all"
var _unmute_label: String = "Unmute all"
var _is_setup: bool = false


## Inject dependencies and connect signals.
## Parameters:
##   music_slider: Slider-like control for music volume.
##   sfx_slider: Slider-like control for sfx volume.
##   mute_button: Toggle button for master mute.
##   music_bus_name: Name of music bus.
##   sfx_bus_name: Name of sfx bus.
##   master_bus_name: Name of master bus.
func setup(
	music_slider: Range,
	sfx_slider: Range,
	mute_button: Button,
	music_bus_name: StringName = &"Music",
	sfx_bus_name: StringName = &"SFX",
	master_bus_name: StringName = &"Master"
) -> void:
	if _is_setup:
		_disconnect_current_controls()
		_is_setup = false
	_music_slider = music_slider
	_sfx_slider = sfx_slider
	_mute_button = mute_button
	_music_bus = music_bus_name
	_sfx_bus = sfx_bus_name
	_master_bus = master_bus_name
	if _music_slider == null:
		push_error("AudioMixControlSystem: missing music slider.")
		return
	if _sfx_slider == null:
		push_error("AudioMixControlSystem: missing sfx slider.")
		return
	if _mute_button == null:
		push_error("AudioMixControlSystem: missing mute button.")
		return
	_configure_slider(_music_slider)
	_configure_slider(_sfx_slider)
	_music_slider.value = _read_bus_linear(_music_bus, DEFAULT_MAX)
	_sfx_slider.value = _read_bus_linear(_sfx_bus, DEFAULT_MAX)
	_apply_bus_linear(_music_bus, _music_slider.value)
	_apply_bus_linear(_sfx_bus, _sfx_slider.value)
	if not _music_slider.value_changed.is_connected(_on_music_changed):
		_music_slider.value_changed.connect(_on_music_changed)
	if not _sfx_slider.value_changed.is_connected(_on_sfx_changed):
		_sfx_slider.value_changed.connect(_on_sfx_changed)
	if not _mute_button.pressed.is_connected(_on_mute_pressed):
		_mute_button.pressed.connect(_on_mute_pressed)
	_master_muted = _read_bus_muted(_master_bus)
	_update_mute_button_text()
	_is_setup = true


func _configure_slider(slider: Range) -> void:
	slider.min_value = DEFAULT_MIN
	slider.max_value = DEFAULT_MAX
	slider.step = DEFAULT_STEP
	if slider is Control:
		var control: Control = slider as Control
		control.focus_mode = Control.FOCUS_ALL


func _on_music_changed(value: float) -> void:
	_unmute_master_if_needed()
	_apply_bus_linear(_music_bus, value)


func _on_sfx_changed(value: float) -> void:
	_unmute_master_if_needed()
	_apply_bus_linear(_sfx_bus, value)


func _on_mute_pressed() -> void:
	var master_idx: int = AudioServer.get_bus_index(_master_bus)
	if master_idx < 0:
		push_error("AudioMixControlSystem: missing master bus " + str(_master_bus))
		return
	if _master_muted:
		AudioServer.set_bus_mute(master_idx, false)
		_master_muted = false
		_update_mute_button_text()
		return
	AudioServer.set_bus_mute(master_idx, true)
	_master_muted = true
	_update_mute_button_text()


func _apply_bus_linear(bus_name: StringName, linear_value: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		push_error("AudioMixControlSystem: missing bus " + str(bus_name))
		return
	linear_value = clampf(linear_value, DEFAULT_MIN, DEFAULT_MAX)
	AudioServer.set_bus_volume_linear(bus_idx, linear_value)


func _unmute_master_if_needed() -> void:
	if not _master_muted:
		return
	var master_idx: int = AudioServer.get_bus_index(_master_bus)
	if master_idx < 0:
		push_error("AudioMixControlSystem: missing master bus " + str(_master_bus))
		return
	AudioServer.set_bus_mute(master_idx, false)
	_master_muted = false
	_update_mute_button_text()


func _read_bus_linear(bus_name: StringName, fallback: float) -> float:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		push_error("AudioMixControlSystem: missing bus " + str(bus_name))
		return fallback
	return AudioServer.get_bus_volume_linear(bus_idx)


func _read_bus_muted(bus_name: StringName) -> bool:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		push_error("AudioMixControlSystem: missing bus " + str(bus_name))
		return false
	return AudioServer.is_bus_mute(bus_idx)


func _update_mute_button_text() -> void:
	if _mute_button == null:
		return
	if _master_muted:
		_mute_button.text = _unmute_label
		return
	_mute_button.text = _mute_label


func _disconnect_current_controls() -> void:
	if _music_slider != null:
		if _music_slider.value_changed.is_connected(_on_music_changed):
			_music_slider.value_changed.disconnect(_on_music_changed)
	if _sfx_slider != null:
		if _sfx_slider.value_changed.is_connected(_on_sfx_changed):
			_sfx_slider.value_changed.disconnect(_on_sfx_changed)
	if _mute_button != null:
		if _mute_button.pressed.is_connected(_on_mute_pressed):
			_mute_button.pressed.disconnect(_on_mute_pressed)
	_music_slider = null
	_sfx_slider = null
	_mute_button = null
