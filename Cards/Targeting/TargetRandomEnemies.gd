class_name TargetRandomEnemies extends TargetingBase
## Target [param number_of_targets] enemies selected randomly [br]
##
## Note that the same enemy may be targeted multiple times [br]

## The number of targets to select [br]
@export var number_of_targets: int = 0


## @Override [br]
## See [TargetingBase] for more information [br]
func _init() -> void:
	cast_type = GlobalEnums.CardCastType.INSTA_CAST


## @Override [br]
## See [TargetingBase] for more information [br]
@warning_ignore("unused_parameter")
func generate_target_list(targeted_entity: Entity) -> Array[Entity]:
	var target_list: Array[Entity] = []
	var enemy_list: Array[Entity] = EnemyManager.current_enemy_group.enemy_list.duplicate()
	var enemy_list_size: int = enemy_list.size()
	for _i: int in range(number_of_targets):
		var random_index: int = randi_range(0,enemy_list_size-1)
		target_list.append(enemy_list[random_index])
		# you can target the same enemy multiple times
	return target_list
