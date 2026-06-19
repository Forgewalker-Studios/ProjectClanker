extends Node2D

## Boots combat test scene audio context.


func _ready() -> void:
	AudioDirector.set_music_context(AudioDirector.MusicContext.EXPLORATION)
