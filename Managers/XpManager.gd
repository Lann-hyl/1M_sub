extends Node
## Global node to manage the XP of the player
##
## This will count the XP of the player, update it when enemies are calmed 
## and give buffs at combat start depending on the level of the XP bar that was reached

## Emitted when the XP is changed. [br]
## Previous and next reference the XP levels after calculating if the player went over next
## For example, we could 4 XP, gain 3 and the levels were 0 and 5, updated to 5 and 12,
# the signal would emit (7, 5, 12, true)
signal xp_changed(new_xp: int, previous_level_xp: int, next_level_xp: int, level_up: bool)

## Current XP of the player
var current_xp: int = 0

## Next amount of XP to reach to get the next buff
var next_xp_level: int

## The last amount of XP that gave a buff
var previous_xp_level: int	

var current_list_of_buffs: Array[BuffBase] = []

## Number of XP point to gather for each level, andd the related buff to apply [br]
## @experimental The buffs will most certainly change to become with infinite duration
@export var xp_levels: Dictionary = {
	5: 	["Strength", Buff_Strength.default()],
	12: ["Healing", Buff_Healing.default()], 
	22: ["Poison duration", Buff_Poison_Duration.default()], 
	37: ["Sooth", Buff_Sooth.default()],
}


func _ready() -> void:
	next_xp_level = xp_levels.keys()[0]
	previous_xp_level = 0
	current_xp = 0
	current_list_of_buffs = []
	for level: int in xp_levels:
		xp_levels[level][1].infinite_duration = true


## Add XP (default to one, could be more for mini-bosses or bosses)
## Also checks if the player reached a new level of XP
func increase(amount: int = 1) -> void:
	if amount >= 1:
		current_xp += amount
		
	else:
		push_warning("Tried to modify the XP with a negative or zero value, amount was: %s" % amount)
		return
		
	if current_xp >= next_xp_level:
		var new_list_of_buffs: Array[BuffBase] = []
		for level: int in xp_levels:
			new_list_of_buffs.append(xp_levels[level][1].duplicate())
			# do it this way in case we jump multiple levels at once
			previous_xp_level = next_xp_level
			next_xp_level = level
			# update the next_xp by searching the first level that's more than current_xp
			if current_xp < level:
				
				break
		# we took the last buff when we shouldn't keep it, remove it
		current_list_of_buffs = new_list_of_buffs.slice(0, new_list_of_buffs.size() - 1)
		xp_changed.emit(current_xp, previous_xp_level, next_xp_level, true)
	else:
		xp_changed.emit(current_xp, previous_xp_level, next_xp_level, false)

func save_data() -> void:
	var save_file: ConfigFile = SaveManager.save_file
	save_file.set_value("XPManager", "current_xp", current_xp)
	
	var error: Error = save_file.save(SaveManager.save_file_path)
	if error:
		print("Error saving player data: ", error)

func load_data() -> void:
	var save_file: ConfigFile = SaveManager.load_save_file()
	if save_file == null:
		return
	
	current_xp = save_file.get_value("XPManager", "current_xp", 0)

func init_data() -> void:
	current_xp = 0
