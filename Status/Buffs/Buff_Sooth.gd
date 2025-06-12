class_name Buff_Sooth extends BuffBase
## Increases the target's ability to soothe others

## @Override
func _init() -> void:
	is_stat_modification = true
	is_on_apply = true
	modifier_name = GlobalEnums.PossibleModifierNames.SOOTH
	EntityStatDictType = GlobalEnums.EntityStatDictType.OFFENSE
	
	
## Default sooth buff which adds 1 to the sooth stat
static func default() -> BuffBase:
	var buff: Buff_Sooth = Buff_Sooth.new()
	var stat_modifier : StatModifiers = StatModifiers.new()
	stat_modifier.temporary_add = 1
	stat_modifier.ready()
	buff.status_modifier_base_value = stat_modifier
	return buff
