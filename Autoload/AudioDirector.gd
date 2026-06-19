extends Node

## Game glue for music, ambience, and SFX using Systems/ audio modules.

const _ProceduralAudioFactory = preload("res://Scripts/ProceduralAudioFactory.gd")

const _PATH_MENU_TRACK: String = "res://Audio/ProtocolOfTheClanker.ogg"
const _PATH_EXPLORATION_A: String = "res://Audio/factory_ambiance1.ogg"
const _PATH_EXPLORATION_B: String = "res://Audio/factory_ambiance2.ogg"
const _PATH_BOSS_TRACK: String = "res://Audio/RustAndRetribution.ogg"
const _PATH_ENDING_TRACK: String = "res://Audio/ForgottenCircuits.ogg"
const _PATH_JUMP: String = "res://Audio/jump.ogg"
const _PATH_ATTACK: String = "res://Audio/impact.ogg"
const _PATH_HURT: String = "res://Audio/hurt.ogg"
const _PATH_DOOR: String = "res://Audio/blip.ogg"
const _PATH_ENDING_STINGER: String = "res://Audio/hit.ogg"
const _PATH_AMBIENCE_BLIP: String = "res://Audio/blip.ogg"
const _PATH_AMBIENCE_SELECT: String = "res://Audio/menu_select.ogg"

enum MusicContext {
	NONE,
	MENU,
	EXPLORATION,
	BOSS,
	ENDING,
}

signal music_context_changed(context: MusicContext)

const _AMBIENCE_MIN_DELAY_SEC: float = 10.0
const _AMBIENCE_MAX_DELAY_SEC: float = 22.0

var _music_jukebox: AudioJukeboxSystem
var _sfx_player: AudioStreamPlayer
var _ambience_timer: Timer
var _cue_scheduler: RandomCueSchedulerSystem = RandomCueSchedulerSystem.new()
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _menu_tracks: Array[AudioStream] = []
var _exploration_tracks: Array[AudioStream] = []
var _boss_tracks: Array[AudioStream] = []
var _ending_tracks: Array[AudioStream] = []
var _ambience_cues: Array[Dictionary] = []

var _jump_stream: AudioStream
var _attack_stream: AudioStream
var _hurt_stream: AudioStream
var _door_stream: AudioStream
var _ending_stinger_stream: AudioStream

var _active_music_context: MusicContext = MusicContext.NONE
var _boss_fight_depth: int = 0


func _ready() -> void:
	_rng.randomize()
	_build_audio_streams()
	_setup_music_jukebox()
	_setup_sfx_player()
	_setup_ambience_timer()
	_configure_ambience_cues()


## Switch music context without restarting when the context is unchanged.
## @param context: Target music playlist.
func set_music_context(context: MusicContext) -> void:
	if _active_music_context == context:
		return

	_active_music_context = context
	_music_jukebox.stop()

	match context:
		MusicContext.MENU:
			_music_jukebox.start_with_tracks(_menu_tracks)
		MusicContext.EXPLORATION:
			_music_jukebox.start_with_tracks(_exploration_tracks)
			_schedule_next_ambience_cue()
		MusicContext.BOSS:
			_music_jukebox.start_with_tracks(_boss_tracks)
			_stop_ambience_timer()
		MusicContext.ENDING:
			_music_jukebox.start_with_tracks(_ending_tracks)
			_stop_ambience_timer()
		_:
			_stop_ambience_timer()

	music_context_changed.emit(context)


## Enter a boss fight layer; only the first call swaps to boss music.
func enter_boss_fight() -> void:
	_boss_fight_depth += 1
	if _boss_fight_depth == 1:
		set_music_context(MusicContext.BOSS)


## Leave a boss fight layer; restore exploration music when depth returns to zero.
func exit_boss_fight() -> void:
	if _boss_fight_depth <= 0:
		return
	_boss_fight_depth -= 1
	if _boss_fight_depth == 0 and _active_music_context == MusicContext.BOSS:
		set_music_context(MusicContext.EXPLORATION)


## Play the jump SFX on the SFX bus.
func play_jump() -> void:
	_play_one_shot(_jump_stream)


## Play the attack SFX on the SFX bus.
func play_attack() -> void:
	_play_one_shot(_attack_stream)


## Play the hurt SFX on the SFX bus.
func play_hurt() -> void:
	_play_one_shot(_hurt_stream)


## Play the door interaction SFX on the SFX bus.
func play_door_interact() -> void:
	_play_one_shot(_door_stream)


## Play the ending stinger once, then switch to ending music.
func play_ending_sequence() -> void:
	_play_one_shot(_ending_stinger_stream)
	set_music_context(MusicContext.ENDING)


func _build_audio_streams() -> void:
	_menu_tracks = [_load_required_stream(_PATH_MENU_TRACK)]
	_exploration_tracks = [
		_load_required_stream(_PATH_EXPLORATION_A),
		_load_required_stream(_PATH_EXPLORATION_B),
	]
	_boss_tracks = [_load_required_stream(_PATH_BOSS_TRACK)]
	_ending_tracks = [_load_required_stream(_PATH_ENDING_TRACK)]

	_jump_stream = _load_required_stream(_PATH_JUMP)
	_attack_stream = _load_required_stream(_PATH_ATTACK)
	_hurt_stream = _load_required_stream(_PATH_HURT)
	_door_stream = _load_required_stream(_PATH_DOOR)
	_ending_stinger_stream = _load_required_stream(_PATH_ENDING_STINGER)


func _load_required_stream(path: String) -> AudioStream:
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		push_error("AudioDirector: failed to load required audio stream at %s" % path)
	return stream


func _setup_music_jukebox() -> void:
	_music_jukebox = AudioJukeboxSystem.new()
	_music_jukebox.name = "MusicJukebox"
	add_child(_music_jukebox)
	_music_jukebox.configure(&"Music", 0.0, Node.PROCESS_MODE_ALWAYS)


func _setup_sfx_player() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SfxPlayer"
	_sfx_player.bus = &"SFX"
	add_child(_sfx_player)


func _setup_ambience_timer() -> void:
	_ambience_timer = Timer.new()
	_ambience_timer.name = "AmbienceTimer"
	_ambience_timer.one_shot = true
	add_child(_ambience_timer)
	_ambience_timer.timeout.connect(_on_ambience_timer_timeout)


func _configure_ambience_cues() -> void:
	_ambience_cues = [
		{"id": "blip", "weight": 1.0, "stream_path": _PATH_AMBIENCE_BLIP},
		{"id": "menu_select", "weight": 0.7, "stream_path": _PATH_AMBIENCE_SELECT},
	]
	_cue_scheduler.set_cues(_ambience_cues)


func _play_one_shot(stream: AudioStream) -> void:
	if stream == null:
		return
	_sfx_player.stream = stream
	_sfx_player.play()


func _schedule_next_ambience_cue() -> void:
	if _active_music_context != MusicContext.EXPLORATION:
		return
	var delay_sec: float = _cue_scheduler.next_delay_seconds(
		_rng,
		_AMBIENCE_MIN_DELAY_SEC,
		_AMBIENCE_MAX_DELAY_SEC
	)
	_ambience_timer.wait_time = delay_sec
	_ambience_timer.start()


func _stop_ambience_timer() -> void:
	_ambience_timer.stop()


func _on_ambience_timer_timeout() -> void:
	if _active_music_context != MusicContext.EXPLORATION:
		return

	var cue: Dictionary = _cue_scheduler.select_next_cue(_rng)
	if cue.is_empty():
		_schedule_next_ambience_cue()
		return

	var stream_path: String = String(cue.get("stream_path", ""))
	if stream_path == "":
		push_error("AudioDirector: ambience cue missing stream_path.")
		_schedule_next_ambience_cue()
		return

	var ambience_stream: AudioStream = _load_required_stream(stream_path)
	_play_one_shot(ambience_stream)
	_schedule_next_ambience_cue()
