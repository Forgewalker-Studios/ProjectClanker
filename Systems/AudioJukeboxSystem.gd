class_name AudioJukeboxSystem
extends Node

## Reusable random jukebox.
## Call [method configure] once, then [method start_with_tracks].
## Use this for non-gameplay-critical background music or ambient playlists.
## This system owns its internal [AudioStreamPlayer].
## Assumes the target audio bus exists.
## Do not use this for timing-critical cue sync unless you add explicit cue controls.
## Default process mode is ALWAYS so playback continues during tree pause unless configured otherwise.

var _player: AudioStreamPlayer
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _tracks: Array[AudioStream] = []
var _last_index: int = -1
var _play_sequence: int = 0


## Configures underlying player.
## Parameters:
##   bus_name: Audio bus to route to.
##   volume_db: Starting volume.
func configure(bus_name: StringName = &"Music", volume_db: float = 0.0, process_mode: ProcessMode = Node.PROCESS_MODE_ALWAYS) -> void:
	if _player == null:
		_player = AudioStreamPlayer.new()
		add_child(_player)
		_player.finished.connect(_on_track_finished)
	_player.process_mode = process_mode
	_rng.randomize()
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		push_warning("AudioJukeboxSystem: missing audio bus " + str(bus_name) + "; falling back to Master.")
		_player.bus = &"Master"
	else:
		_player.bus = bus_name
	_player.volume_db = volume_db


## Starts playback from an array of streams.
## Non-audio entries are ignored.
func start_with_tracks(streams: Array) -> void:
	if _player == null:
		configure()
	_play_sequence += 1
	var sequence: int = _play_sequence
	_tracks.clear()
	var i: int = 0
	while i < streams.size():
		var entry: Variant = streams[i]
		if entry is AudioStream:
			_tracks.append(entry as AudioStream)
		i += 1
	if _tracks.size() == 0:
		push_warning("AudioJukeboxSystem: no playable tracks.")
		return
	call_deferred("_play_deferred", sequence)


## Stops playback and clears playlist.
func stop() -> void:
	_play_sequence += 1
	if _player != null:
		_player.stop()
	_tracks.clear()
	_last_index = -1


func _play_deferred(sequence: int) -> void:
	if sequence != _play_sequence:
		return
	# Two-frame defer avoids first-play race conditions when callers start immediately
	# after node creation or scene transitions.
	await get_tree().process_frame
	if sequence != _play_sequence:
		return
	await get_tree().process_frame
	if sequence != _play_sequence:
		return
	_play_next_random()


func _play_next_random() -> void:
	if _tracks.size() == 0:
		return
	var idx: int = _pick_track_index()
	var stream: AudioStream = _tracks[idx]
	if stream == null:
		push_warning("AudioJukeboxSystem: encountered null stream.")
		return
	_player.stream = stream
	_player.play()
	_last_index = idx
	if not _player.playing:
		push_warning("AudioJukeboxSystem: play() did not start.")


func _pick_track_index() -> int:
	var last: int = _tracks.size() - 1
	if last <= 0:
		return 0
	var idx: int = _rng.randi_range(0, last)
	# Avoid immediate repeats for better perceived variety.
	if idx == _last_index:
		idx += 1
		if idx > last:
			idx = 0
	return idx


func _on_track_finished() -> void:
	_play_next_random()
