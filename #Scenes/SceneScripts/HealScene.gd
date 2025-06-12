extends Control

# If you are searching for the actual logic of the event, look at the script for the button
func _ready() -> void:
	AudioManager.start_music(GlobalEnums.MusicTrack.HEAL)
	SaveManager.execute_save()
