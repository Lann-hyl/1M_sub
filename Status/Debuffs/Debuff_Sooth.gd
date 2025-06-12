class_name Debuff_Sooth extends DebuffBase
## Reduce the target's ability to soothe others

## @Override
func _init() -> void:
	is_stat_modification = true
	is_on_apply = true
	modifier_name = GlobalEnums.PossibleModifierNames.SOOTH
	EntityStatDictType = GlobalEnums.EntityStatDictType.OFFENSE
	
	
## Default sooth debuff which removes 1 to the sooth stat
static func default() -> DebuffBase:
	var buff: Debuff_Sooth = Debuff_Sooth.new()
	var stat_modifier : StatModifiers = StatModifiers.new()
	stat_modifier.temporary_add = -1
	stat_modifier.ready()
	buff.status_modifier_base_value = stat_modifier
	return buff
