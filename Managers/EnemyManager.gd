extends Node
## Globally accessible for easy access to the enemies
## They are for now only accessible through the battler which is not very practical

## Distribution of enemies over the floors [br]
## The values are arrays of PackedScene [br]
## The keys are of format (X,Y,Z) with X the tree section from 1 to 3, 
## Y the lower percent at which the enemy groups of the corresponding value are found,
## Z the higher percent at which the enemy groups of the corresponding vlaue are found [br]
## The intervals defined by the values are continuous, successive and non-overlapping.
@export var enemy_group_distribution: Dictionary = {
	[1, 0, 20]: [], # an array of packed scene for enemy groups
	[1, 20, 40]: [],
	[1, 40, 60]: [],
	[1, 60, 80]: [],
	[1, 80, 100]: [],
	[2, 0, 20]: [], # section 2
	[2, 20, 40]: [],
	[2, 40, 60]: [],
	[2, 60, 80]: [],
	[2, 80, 100]: [],
	[3, 0, 20]: [], # section 3
	[3, 20, 40]: [],
	[3, 40, 60]: [],
	[3, 60, 80]: [],
	[3, 80, 100]: [],
}

## The group of enemies currently being used, set at the start of the combat [br]
var current_enemy_group: EnemyGroup

## The packed scene corresponding to the group of enemies, this is used to keep track of it between saves [br]
## DO NOT FORGET to set this back to null once the fight is done [br]
## The reset is handled via signals to be sure to not forget it when changing the battler
var current_enemy_group_packed: PackedScene = null

## The last recorded lower bound of the current sub-section
var current_lower_bound: int = enemy_group_distribution.keys()[0][1]
## The last recorded higher bound of the current sub-section
var current_higher_bound: int = enemy_group_distribution.keys()[0][2]
## The last used array of enemy group
var enemy_group_array: Array[PackedScene]
## The shuffled version of the `enemy_group_array`
var shuffled_enemy_group_array: Array[PackedScene] = []

func _ready() -> void:
	if enemy_group_array.is_empty():
		enemy_group_array.assign(enemy_group_distribution.values()[0])
	PhaseManager.on_event_win.connect(_clear_data)
	PhaseManager.on_defeat.connect(_clear_data)


## This calls the inner function that actually chooses the enemy group [br]
## This is done to save the packed scene in this EnemyManger before it is returned
func choose_enemy_group() -> PackedScene:
	if current_enemy_group_packed != null:
		# if we load from a save
		return current_enemy_group_packed
	var packed_enemy_group: PackedScene = _choose_enemy_group_inner()
	current_enemy_group_packed = packed_enemy_group
	return packed_enemy_group

## Chooses an enemy group in the following way: [br]
## - Check if the player is in the same sub-section as the previous time this function was called [br]
## - Choose an array of enemy group depending on player position if either sub-section changed, or the array to choose from is empty [br]
## - Shuffle it, pop the last element of that array
func _choose_enemy_group_inner() -> PackedScene:
	if current_enemy_group != null:
		return current_enemy_group_packed
	if DebugVar.DEBUG_USE_TEST_ENEMY_GROUP:
		return load("res://Entity/Enemy/EnemyGroup/test_group.tscn") # return a test group
	var height_percent_position: float = MapManager.get_map_percent_with_player_position()
	if (current_lower_bound <= height_percent_position && current_higher_bound > height_percent_position):
		# meaning we stayed in the same sub-section of the map, keep the same array of enemies
		if shuffled_enemy_group_array.is_empty():
			shuffled_enemy_group_array = enemy_group_array.duplicate()
			shuffled_enemy_group_array.shuffle()

		return shuffled_enemy_group_array.pop_back()
	else:
		# we entered a new sub-section, search the corresponding array of enemy group
		for key: Array in enemy_group_distribution:
			# include lower bound, exclude higher bound
			if (key[1] <= height_percent_position && key[2] > height_percent_position):
				# update lower and higher bound
				current_lower_bound = key[1]
				current_higher_bound = key[2]
				var new_enemy_group_array: Array = enemy_group_distribution[key]
				if new_enemy_group_array.is_empty():
					break # go to load the test group
				# assign does NOT perform a copy, but we are not modifying this array, thus it's fine for now
				# if later we need to modify the array, think of changing this to perform a copy
				enemy_group_array.assign(new_enemy_group_array)
				# duplicate will only copy the arrays, not the elements (but are currently not modifying those)
				shuffled_enemy_group_array = enemy_group_array.duplicate()
				shuffled_enemy_group_array.shuffle()
				return shuffled_enemy_group_array.pop_back()
	push_error("No suitable sub-section or enemy has been found, returning a default enemy group")
	return load("res://Entity/Enemy/EnemyGroup/test_group.tscn") # return the test group to not crash the game

func save_data() -> void:
	var save_file: ConfigFile = SaveManager.save_file
	save_file.set_value("EnemyManager", "current_enemy_group", current_enemy_group)
	save_file.set_value("EnemyManager", "current_enemy_group_packed", current_enemy_group_packed)
	save_file.set_value("EnemyManager", "current_lower_bound", current_lower_bound)
	save_file.set_value("EnemyManager", "current_higher_bound", current_higher_bound)
	save_file.set_value("EnemyManager", "enemy_group_array", enemy_group_array)
	save_file.set_value("EnemyManager", "shuffled_enemy_group_array", shuffled_enemy_group_array)

	var error: Error = save_file.save(SaveManager.save_file_path)
	if error:
		push_error("Error saving inventory data: ", error)

func load_data() -> void:
	var save_file: ConfigFile = SaveManager.load_save_file()
	if save_file == null:
		return

	if save_file.has_section_key("EnemyManager", "current_enemy_group"):
		current_enemy_group = save_file.get_value("EnemyManager", "current_enemy_group")
	if save_file.has_section_key("EnemyManager", "current_enemy_group_packed"):
		current_enemy_group_packed = save_file.get_value("EnemyManager", "current_enemy_group_packed")
	if save_file.has_section_key("EnemyManager", "current_lower_bound"):
		current_lower_bound = save_file.get_value("EnemyManager", "current_lower_bound")
	if save_file.has_section_key("EnemyManager", "current_higher_bound"):
		current_higher_bound = save_file.get_value("EnemyManager", "current_higher_bound")
	if save_file.has_section_key("EnemyManager", "enemy_group_array"):
		enemy_group_array = save_file.get_value("EnemyManager", "enemy_group_array")
	if save_file.has_section_key("EnemyManager", "shuffled_enemy_group_array"):
		shuffled_enemy_group_array = save_file.get_value("EnemyManager", "shuffled_enemy_group_array")

## Clear the data regarding the current enemy group being fought
func _clear_data() -> void:
	current_enemy_group = null
	current_enemy_group_packed = null
