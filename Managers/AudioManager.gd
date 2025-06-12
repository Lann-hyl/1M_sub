extends Node


# Music
var battle_area_1: AudioStream = preload("res://Audio/Battle/area_1.wav")
var battle_area_2: AudioStream = preload("res://Audio/Battle/area_2.wav")
var battle_area_3: AudioStream = preload("res://Audio/Battle/area_3.wav")
var boss: AudioStream = preload("res://Audio/Battle/boss_1.wav")
var heal_event: AudioStream = preload("res://Audio/World/heal.wav")
var shop_event: AudioStream = preload("res://Audio/World/shop.wav")
var main_menu: AudioStream = preload("res://Audio/MainMenu/cicadas.wav")

var music_dictionary: Dictionary = {
	GlobalEnums.MusicTrack.AREA_ONE: battle_area_1,
	GlobalEnums.MusicTrack.AREA_TWO: battle_area_2,
	GlobalEnums.MusicTrack.AREA_THREE: battle_area_3,
	GlobalEnums.MusicTrack.BOSS: boss,
	GlobalEnums.MusicTrack.HEAL: heal_event,
	GlobalEnums.MusicTrack.SHOP: shop_event,
	GlobalEnums.MusicTrack.MAIN_MENU: main_menu
}

# SFX
var uuuuu: AudioStream = preload("res://Audio/fauna_uuu_test.mp3")

var sfx_dictionary: Dictionary = {
	GlobalEnums.SoundEffect.UUUUU: uuuuu
}

var music_stream: AudioStreamPlayer = AudioStreamPlayer.new()
var sfx_stream: AudioStreamPlayer = AudioStreamPlayer.new()

var current_song: GlobalEnums.MusicTrack = GlobalEnums.MusicTrack.NO_TRACK

func _ready() -> void:
	add_child(music_stream)
	add_child(sfx_stream)

func start_music(song: GlobalEnums.MusicTrack) -> void:
	if current_song == song or song == GlobalEnums.MusicTrack.NO_TRACK:
		return
	
	if music_stream.playing and current_song != song:
		var volume_tween: Tween = create_tween()
		volume_tween.tween_property(music_stream, "volume_db", -100, 1)
		volume_tween.tween_callback(_on_volume_fade_finished.bind(song))
	else:
		_on_volume_fade_finished(song)

func stop_music() -> void:
	var volume_tween: Tween = create_tween()
	volume_tween.tween_property(music_stream, "volume_db", -100, 0.25)
	volume_tween.tween_callback(_on_volume_fade_stop)

func _on_volume_fade_stop() -> void:
	current_song = GlobalEnums.MusicTrack.NO_TRACK
	music_stream.volume_db = 0
	music_stream.stop()

func _on_volume_fade_finished(song: GlobalEnums.MusicTrack) -> void:
	music_stream.stream = _get_music_track(song)
	music_stream.volume_db = 0
	music_stream.play()
	current_song = song

func _get_music_track(song: GlobalEnums.MusicTrack) -> AudioStream:
	return music_dictionary[song]

func play_sfx(sfx: GlobalEnums.SoundEffect) -> void:
	sfx_stream.stream = _get_sound_effect(sfx)
	sfx_stream.volume_db = 0
	sfx_stream.play()

func _get_sound_effect(sfx: GlobalEnums.SoundEffect) -> AudioStream:
	return sfx_dictionary[sfx]
