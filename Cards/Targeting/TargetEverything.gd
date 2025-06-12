class_name TargetEverything extends TargetingBase
## Target every entity in the current fight. [br]
##
## For now, this will target all enemies and the player. [br]
## This might later be modified to include targeting minions that could be spawned by the player.

## @Override [br]
## See [TargetingBase] for more information [br]
func _init() -> void:
	cast_type = GlobalEnums.CardCastType.INSTA_CAST


## @Override [br]
## See [TargetingBase] for more information [br]
@warning_ignore("unused_parameter")
func generate_target_list(targeted_entity:Entity) -> Array[Entity]:
	var targets: Array[Entity] = EnemyManager.current_enemy_group.enemy_list.duplicate()
	targets.append(PlayerManager.player)
	return targets
