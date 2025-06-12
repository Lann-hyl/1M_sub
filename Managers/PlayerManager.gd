extends Node
## Global getter for the player.
##
## Since we only have one player, you can easily get the player from anywhere by calling
## PlayerManager.player.

signal on_player_initialized

var player: Player


## This is updated when a room button on the MapUI is clicked. [br]
## The actual connection is done via the ready function that sends a signal in the [RoomUI] [br]
## The position of the player on the map (by default, a position that doesn't exist)
var player_position: Vector2i = Vector2i(-1,-1):
	set(position):
		player_position = position
		if player_position != Vector2i(-1, -1):
			is_player_initial_position_set = true
	get:
		return player_position

## Check if the player has selected a starting position
var is_player_initial_position_set: bool

## The actual room the player is in. [br]
var player_room: RoomBase = null:
	get:
		if player_position == Vector2i(-1, -1):
			return null
		return MapManager.current_map.rooms[player_position.y][player_position.x]

## A flag to check if the player is allowed to move on the map. [br]
## This is set to false at the start of an event, and set to true once the event ends [br]
## This is set to true by default as it allows the player to move to the first floor of the map
var is_map_movement_allowed: bool = true

var player_persistent_data: PlayerPersistentData = null:
	get:
		return player_persistent_data


func _ready() -> void:
	player = null
	is_player_initial_position_set = false

func save_player() -> void:
	var save_file: ConfigFile = SaveManager.save_file
	
	save_file.set_value("Player", "position", player_position)
	save_file.set_value("Player", "player_room", player_room)
	save_file.set_value("Player", "player_persistent_data", player_persistent_data)
	
	var error: Error = save_file.save(SaveManager.save_file_path)
	if error:
		push_error("Error saving player data: ", error)

func load_player() -> void:
	var save_file: ConfigFile = SaveManager.load_save_file()
	if save_file == null:
		return
	
	if save_file.has_section_key("Player", "position"):
		player_position = save_file.get_value("Player", "position")
	
	if save_file.has_section_key("Player", "player_room"):
		player_room = save_file.get_value("Player", "player_room")
	
	if save_file.has_section_key("Player", "player_persistent_data"):
		player_persistent_data = save_file.get_value("Player", "player_persistent_data") as PlayerPersistentData

func set_player(in_player: Player) -> void:
	player = in_player
	if player != null:
		on_player_initialized.emit()


func create_persistent_data() -> void:
	player_persistent_data = PlayerPersistentData.new()

func init_data() -> void:
	player = null
	is_player_initial_position_set = false
	player_position = Vector2i(-1,-1)
	player_room = null
	is_map_movement_allowed = true

## Checks if the player is in a given room
func is_player_in_room(room: RoomBase) -> bool:
	if room == null:
		return false
		
	var map_rooms: Array[Array] = MapManager.current_map.rooms
	
	return room == map_rooms[player_position.y][player_position.x]
