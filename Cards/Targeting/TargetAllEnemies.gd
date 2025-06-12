class_name  TargetAllEnemies extends TargetingBase
## Target all enemies in the scene [br]
##
## That's it


## @Override [br]
## See [TargetingBase] for more information [br]
func _init() -> void:
	cast_type = GlobalEnums.CardCastType.INSTA_CAST

	

## @Override [br]
## See [TargetingBase] for more information [br]
@warning_ignore("unused_parameter")
func generate_target_list(targeted_entity: Entity) -> Array[Entity]:
	return EnemyManager.current_enemy_group.enemy_list 
