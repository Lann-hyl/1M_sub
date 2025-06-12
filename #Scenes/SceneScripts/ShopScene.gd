extends Control
class_name ShopScene

func _ready() -> void:
	AudioManager.start_music(GlobalEnums.MusicTrack.SHOP)
	
	# This code has to happen after the map has done '.on_event_started' [br]
	# so I just put a .1 delay on it
	var timer : SceneTreeTimer = get_tree().create_timer(0.1)  
	timer.timeout.connect(_on_start_with_delay)


## This code has to happen after the map has done '.on_event_started' [br]
## so I just put a .1 delay on it
func _on_start_with_delay() -> void:
	SaveManager.execute_save()
	
	if(PlayerManager.player_room != null):
		PlayerManager.player_room.room_event.on_event_ended()

func _stock_shop() -> void:
	pass
