extends Node2D

## * We do this to properly init the battle state
## Before, the testing scene was the main scene so it was properly started by the phase manager
## Now that the main scene is the main menu and we load the testing scene from there, we init to properly init the game state 

func _ready() -> void:
	_play_music()
	SaveManager.execute_save()
	PhaseManager.initialize_game()

func _play_music() -> void:
	var percentage_complete: float = MapManager.get_map_percent_with_player_position()
	var music_track: GlobalEnums.MusicTrack
	if MapManager.is_on_last_floor():
		music_track = GlobalEnums.MusicTrack.BOSS
	elif percentage_complete <= 33:
		music_track = GlobalEnums.MusicTrack.AREA_ONE
	elif percentage_complete > 33 and percentage_complete <= 66:
		music_track = GlobalEnums.MusicTrack.AREA_TWO
	elif percentage_complete > 66 and percentage_complete <= 99:
		music_track = GlobalEnums.MusicTrack.AREA_THREE
	
	AudioManager.start_music(music_track)
