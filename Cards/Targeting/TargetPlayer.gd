class_name TargetPlayer extends TargetingBase
## Target the player
##
## This is used to apply effects to self [br]
## This is not used by enemies to target the player.

## @Override [br]
## See [TargetingBase] for more information [br]
func _init() -> void:
	cast_type = GlobalEnums.CardCastType.INSTA_CAST

	
## @Override [br]
## See [TargetingBase] for more information [br]
@warning_ignore("unused_parameter")
func generate_target_list(targeted_entity: Entity) -> Array[Entity]:
	return [PlayerManager.player]
