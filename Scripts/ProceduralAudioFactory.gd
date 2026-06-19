class_name ProceduralAudioFactory
extends RefCounted

## Builds short placeholder [AudioStreamWAV] tones for jam audio before real assets ship.

const DEFAULT_SAMPLE_RATE: int = 22050


## Create a mono 8-bit sine tone.
## @param frequency_hz: Tone frequency.
## @param duration_sec: Playback length in seconds.
## @param volume_linear: Peak amplitude from 0 to 1.
## @return: Playable WAV stream.
static func create_tone_stream(
	frequency_hz: float,
	duration_sec: float,
	volume_linear: float = 0.5
) -> AudioStreamWAV:
	var sample_count: int = maxi(1, int(DEFAULT_SAMPLE_RATE * duration_sec))
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count)

	var index: int = 0
	while index < sample_count:
		var time_sec: float = float(index) / float(DEFAULT_SAMPLE_RATE)
		var fade: float = 1.0 - (float(index) / float(sample_count))
		var sample: float = sin(TAU * frequency_hz * time_sec) * volume_linear * fade
		var byte_value: int = int(clampf(sample * 127.0 + 128.0, 0.0, 255.0))
		data[index] = byte_value
		index += 1

	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = DEFAULT_SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream


## Create a looping low drone for menu or exploration music placeholders.
## @param base_frequency_hz: Root tone frequency.
## @param duration_sec: Loop length in seconds.
## @return: Looping WAV stream.
static func create_loop_drone_stream(base_frequency_hz: float, duration_sec: float) -> AudioStreamWAV:
	var sample_count: int = maxi(1, int(DEFAULT_SAMPLE_RATE * duration_sec))
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count)

	var index: int = 0
	while index < sample_count:
		var time_sec: float = float(index) / float(DEFAULT_SAMPLE_RATE)
		var root: float = sin(TAU * base_frequency_hz * time_sec)
		var overtone: float = sin(TAU * base_frequency_hz * 1.5 * time_sec) * 0.35
		var sample: float = (root + overtone) * 0.22
		var byte_value: int = int(clampf(sample * 127.0 + 128.0, 0.0, 255.0))
		data[index] = byte_value
		index += 1

	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = DEFAULT_SAMPLE_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	stream.data = data
	return stream
