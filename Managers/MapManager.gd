extends Node2D
## Class to manage backend for rooms (generation and such)

##
## With the map width array being [code][1,3,5,3,1][/code], the map looks like that (O are accessible positions, X are null): [br]
## [codeblock]
## X  X  O  X  X
## X  O  O  O  X
## O  O  O  O  O
## X  O  O  O  X
## X  X  O  X  X
## [/codeblock]
## if the map width array is [code][3,3,5,3,1][/code], the map looks like that (O are accessible positions, X are null): [br]
## [codeblock]
## X  X  O  X  X
## X  O  O  O  X
## O  O  O  O  O
## X  O  O  O  X
## X  O  O  O  X

## The map we are on
var current_map: MapBase
## The width of all the map's floors [br]
## Starts with width of first floor
## Width should follow the following rules: [br]
## - Width should be odd (for symmetry + padding reason) [br]
## - Width should not increase or decrease by more than 2 per floor (this makes it certain all rooms on the map are accessible [br]
var map_width_array: Array[int] = [1, 3, 5, 7, 9, 11, 9, 7, 5, 3, 1]

## Room events that we do not want to be consecutive
const no_consecutive_room_event: Array[String] = ["shop", "heal"]

## List containing all events that we will pick from to populate the map
var event_list: Array[GlobalEnums.EventType]
const event_count_deviation: float = 0.5

## Number of times a room type can be picked. If we cannot find a suitable room type in map_reset_limit tries, we regenerate all room events
const map_reset_limit: int = 10

#map_floors_width changes the width of the map's floors
## Generates and Populates a map with rooms that have random room types. More in depth algorithms will be added in the future
func create_map(map_floors_width: Array[int] = map_width_array) -> MapBase:
	var _map: MapBase = MapBase.new()
	# 2d array to return. this will be populated with rooms
	var _grid: Array[Array] = []
	var _max_floor_size: int = map_floors_width.max()
	# loop through the floor, add padding, rooms and padding again
	for index_height: int in range(map_floors_width.size()):
		
		var _floor_width: int = map_floors_width[index_height]
		# ! only works if the size of the floor is odd

		var _padding_size: int = floor((_max_floor_size - _floor_width) / 2.)
		
		var _padding: Array = []
		_padding.resize(_padding_size)
		_padding.fill(null)
		_grid.append([])
		_grid[index_height].append_array(_padding)
		

		# loop through positions of the grid and assign a room type
		for index_width: int in range(map_floors_width[index_height]):
			# create a new room with the null type and give it its position
			var _generated_room: RoomBase = RoomBase.new()
			_generated_room.room_event = null
			_generated_room.room_position = Vector2i(index_width + _padding_size, index_height)
			# put the new room on the grid
			_grid[index_height].append(_generated_room as RoomBase)
		_grid[index_height].append_array(_padding)
	_map.rooms = _grid

	# Assign room type to all rooms
	assign_events(_map)

	return _map as MapBase

## Checks if the current room event upholds all map generation rules
func is_room_event_correct(current_room: RoomBase, map: MapBase = current_map) -> bool:
	## Rule 0: A room cannot have no event
	if current_room.room_event == null:
		return false
	
	var current_room_event_name: String = current_room.room_event.get_event_name()

	## Rule 1: No Heal room before half of the map
	if current_room_event_name == "heal" && current_room.room_position.y < int(floor(map.rooms.size() / 2.0)):
		return false


	## Rule 2: Cannot have 2 consecutive Heal or Shop rooms
	# We need to check the parents (We define parents as rooms from the floor below that can reach the current room) 
	# if current room event is shop or heal
	if current_room_event_name in no_consecutive_room_event:
		# Get the parent rooms' types
		var _parent_events: Array[String] = []
		var _parent_y: int = current_room.room_position.y - 1
		
		if _parent_y >= 0:
			for delta_x: int in [-1, 0, 1]:
				var _parent_x: int = current_room.room_position.x + delta_x
				if _parent_x >= 0 && _parent_x < map.rooms[_parent_y].size() && map.rooms[_parent_y][_parent_x] != null:
					_parent_events.append(map.rooms[_parent_y][_parent_x].room_event.get_event_name())

		# Check if current room has the same type as one of its parent room
		if current_room_event_name in _parent_events:
			return false


	## Rule 3: There must be at least 2 room types among destinations of Rooms that have 2 or more Paths going out. 
	## Since the events of the rooms on the right of current room ((x+i,y), i=1,2,...) have not been generated yet, 
	## we don't need to take them into account. We only check neighbors on the left: (x-2,y), (x-1,y) and (x,y) 
	## Note: We make sure the two leftmost and rightmost rooms of the floor have different events, 
	## since they could be the only destinations of a room from the previous floor (happens when current floor's size 
	## is smaller or equal than previous)
	var _neighbors_events: Array[String] = []
	var delta_xs: Array[int] = []

	# If rightmost room of floor
	if current_room.room_position.x == map.rooms[current_room.room_position.y].size() - 1 or map.rooms[current_room.room_position.y][current_room.room_position.x + 1] == null:
		delta_xs = [-1, 0]
	else:
		delta_xs = [-2, -1, 0]
		
	# Get the neighbor and current rooms types
	var _neighbor_y: int = current_room.room_position.y
	for delta_x: int in delta_xs:
		var _neighbor_x: int = current_room.room_position.x + delta_x
		if _neighbor_x >= 0 && _neighbor_x < map.rooms[_neighbor_y].size() && map.rooms[_neighbor_y][_neighbor_x] != null:
			_neighbors_events.append(map.rooms[_neighbor_y][_neighbor_x].room_event.get_event_name())

	# If our current room has no neighbors on the left, ignore this rule
	if _neighbors_events.size() >= 2:
		var _unique: Array[String] = []

		# Remove duplicates
		for event in _neighbors_events:
			if not _unique.has(event):
				_unique.append(event)
		
		# If there is only one event type among all rooms, redraw event
		if _unique.size() == 1:
			return false


	## Rule 4: No Heal rooms two floors before Boss
	if (current_room_event_name == "heal" && current_room.room_position.y == map.rooms.size() - 3):
		return false

	return true

## Creates the list that contains all events that we will be picking from to populate the map
## The number of occurences of each event is defined by the total number of rooms times the probability of the event set in Global_var.gd
## We then add some extra events (deviation) to avoid being locked, there are rules that could prevent the remaining event types to be picked, resulting in a deadlock
## While the number of each event is not exactly the expected number, it should be close enough to what we want
func create_event_list() -> void:
	event_list = []
	var total_nb_rooms: int = 0
	for nb: int in map_width_array:
		total_nb_rooms += nb
	
	for event_type: GlobalEnums.EventType in GlobalVar.EVENTS_PROBABILITIES:
		var event_type_list: Array[GlobalEnums.EventType] = []
		var event_count: int = floor(total_nb_rooms * GlobalVar.EVENTS_PROBABILITIES[event_type]/100)
		
		event_type_list.resize(event_count + ceil(event_count*event_count_deviation))
		event_type_list.fill(event_type)
		event_list.append_array(event_type_list)

## Pick an event randomly from the list
func pick_room_type() -> GlobalEnums.EventType:
	return event_list.pick_random()

## Assign events to existing rooms with set probabilities.
func assign_events(map: MapBase = current_map) -> void:
	create_event_list()
	var map_reset_counter: int = 0
	
	# Scan the whole map, assign events to valid rooms
	for index_height: int in range(map.rooms.size()):
		for index_width: int in range(map.rooms[index_height].size()):
			# If not a room, ignore
			if map.rooms[index_height][index_width] == null:
				continue
			
			var _current_room: RoomBase = map.rooms[index_height][index_width]

			# Set fixed rooms here
			if index_height == map.rooms.size() - 2:
				# Rooms before boss are Heal rooms
				_current_room.room_event = EventHeal.new()

			elif index_height == map.rooms.size() - 1:
				# Boss room, TO BE ASSIGNED
				_current_room.room_event = EventMob.new()

			else:
				var room_type: GlobalEnums.EventType
				map_reset_counter = 0
				while not is_room_event_correct(_current_room, map) and map_reset_counter < map_reset_limit:
					map_reset_counter += 1
					room_type = pick_room_type()
					_current_room.room_event = GlobalEnums.choose_event_from_type(room_type)

				# If we couldn't find a suitable room type in map_reset_limit tries, we regenerate the map
				if map_reset_counter >= map_reset_limit:
					for reset_index_height: int in range(map.rooms.size()):
						for reset_index_width: int in range(map.rooms[reset_index_height].size()):
							if map.rooms[reset_index_height][reset_index_width] == null:
								continue

							map.rooms[reset_index_height][reset_index_width].room_event = null
					assign_events(map)
					return
				
				# If assigned, we remove the event from the list only after we are sure it does not conflict with any rules
				event_list.erase(room_type)


## Create a map with a width array

func _ready() -> void:
	if _has_current_map_saved():
		print("load map data")
		load_map_data()
	if not is_map_initialized():
		#map_width_array = [1, 3, 5, 7, 9, 11, 9, 7, 5, 3, 1]
		current_map = create_map()


		##### DEBUG #####
		# Count number of each event
		if DebugVar.DEBUG_PRINT_EVENT_COUNT:
			debug_print_event_count()

func _has_current_map_saved() -> bool:
	var save_file: ConfigFile = SaveManager.save_file
	return save_file.has_section_key("MapManager", "current_map")

## checks if the map exists
func is_map_initialized() -> bool:
	return current_map != null

func set_room_light_data(room: RoomBase) -> void:
	current_map.rooms[room.room_position.y][room.room_position.x].light_data = room.light_data

func save_map_data() -> void:
	var save_file: ConfigFile = SaveManager.save_file
	save_file.set_value("MapManager", "map_width_array", map_width_array)
	save_file.set_value("MapManager", "current_map", current_map)
	var error: Error = save_file.save(SaveManager.save_file_path)
	if error:
		print("Error saving player data: ", error)

func load_map_data() -> void:
	var save_file: ConfigFile = SaveManager.load_save_file()
	if save_file == null:
		return
	
	if save_file.has_section_key("MapManager", "current_map"):
		current_map = save_file.get_value("MapManager", "current_map")
	
	if save_file.has_section_key("MapManager", "map_width_array"):
		map_width_array = save_file.get_value("MapManager", "map_width_array")

func init_data() -> void:
	current_map = create_map()

## DEBUG
## Prints the number and percentage of each event type, and the corresponding expected number as well
func debug_print_event_count() -> void:
	var events: Dictionary = {}
	var total_nb_rooms: int = 0
	var expected_probabilities: Dictionary = {}
	
	# Loop over event probabilities to create a dict<event_name, event_probability>
	# since we use the event names to identify the type of event, 
	# and we do not currently have a way to get the EventType from the Event Resource (and thus cannot get the probability from the resource)
	for event_type: GlobalEnums.EventType in GlobalVar.EVENTS_PROBABILITIES:
		expected_probabilities[GlobalEnums.choose_event_from_type(event_type).get_event_name()] = GlobalVar.EVENTS_PROBABILITIES[event_type]
	
	for index_height: int in range(current_map.rooms.size()):
		for index_width: int in range(current_map.rooms[index_height].size()):
			if current_map.rooms[index_height][index_width] == null:
				continue
				
			var event: String = current_map.rooms[index_height][index_width].room_event.get_event_name()
			if not event in events:
				events[event] = 0
			events[event] += 1
			total_nb_rooms += 1
	for k: String in events:
		print("Event " + k + " has " + str(events[k]) + " rooms (expected: "+ str(float(expected_probabilities[k] * total_nb_rooms/100.0)).pad_decimals(2) +"). (The percentage is " + str(float(events[k]) * 100 / total_nb_rooms).pad_decimals(2) + "%, expected: " + str(expected_probabilities[k]) + "%)")
	print("Total number of rooms generated: " + str(total_nb_rooms))
	

## Returns the percent height of the player in the current map
func get_map_percent_with_player_position() -> float:
	var player_position: Vector2i = PlayerManager.player_position
	var number_of_floors: int = map_width_array.size()
	var player_y_floor: int = player_position.y
	return (player_y_floor as float / number_of_floors as float) * 100

func is_on_last_floor() -> bool:
	var number_of_floors: int = map_width_array.size()
	
	# Add one since we want to compare the number of floors and player position is zero-index based
	var player_position_y: int = PlayerManager.player_position.y + 1
	
	return number_of_floors == player_position_y
