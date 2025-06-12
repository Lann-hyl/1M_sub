class_name TargetAllAllies extends TargetingBase
## Target all the allies of the player
##
## This currently includes only the player (meaning it does the same thing as [TargetPlayer]) [br]
## This might change later if minions / more allies are added


## @Override [br]
## See [TargetingBase] for more information [br]
func _init() -> void:
	cast_type = GlobalEnums.CardCastType.INSTA_CAST


## @Override [br]
## See [TargetingBase] for more information [br]
@warning_ignore("unused_parameter")
func generate_target_list(targeted_entity: Entity) -> Array[Entity]:
	return [PlayerManager.player]
	# ? this might change if we decide that the player can summon minions
	# ? should it be done with get_party_component instead ?
