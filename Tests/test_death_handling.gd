extends TestBase
## Tests for things relating to death handling things

## Watch signals and disconnect functions to ensure that nothing irrelevant is called
func before_all() -> void:
	PhaseManager.on_event_win.disconnect(SceneManager.on_event_win)
	PhaseManager.on_defeat.disconnect(SceneManager.on_defeat)

## @Override
func before_each() -> void:
	super()
	watch_signals(PhaseManager)
	
# No typing for argument as if it's already been freed it doesn't have one
@warning_ignore("untyped_declaration")
func _free_if_valid(node) -> void:
	if is_instance_valid(node):
		node.free()

# @Override
func after_each() -> void:
	_free_if_valid(_player)
	_free_if_valid(_enemy)
	_free_if_valid(_enemy_2)
	_battler.free()
	assert_no_new_orphans("Orphans still exist, please free up test resources.")
	

func test_player_death_during_enemy_turn() -> void:
	_player.get_health_component()._set_health(1)
	_battler._enemy_turn()
	assert_eq(_player.get_health_component().current_health, 0)
	assert_signal_emitted(PhaseManager, "on_defeat")


func test_check_and_handle_battle_end_player_death() -> void:
	_player_health_component._set_health(0)
		
	_battler._check_and_handle_battle_end()

	assert_signal_emitted(PhaseManager, "on_defeat")
	

func test_check_and_handle_battle_end_enemy_death() -> void:
	_battler._enemy_list = []
	
	_battler._check_and_handle_battle_end()

	assert_signal_emitted(PhaseManager, "on_event_win")
	
	
func test_handle_enemy_deaths_none() -> void:
	assert_eq(_enemy_list.size(), 2)
	_battler._handle_enemy_deaths()
	assert_eq(_enemy_list.size(), 2)
	
	
func test_handle_enemy_deaths_single() -> void:
	_enemy_health_component._set_health(0)
	
	assert_eq(_enemy_list.size(), 2)
	_battler._handle_enemy_deaths()
	assert_eq(_enemy_list.size(), 1)
	assert_true(_enemy.is_queued_for_deletion())
	await get_tree().process_frame
	assert_false(is_instance_valid(_enemy))
	
	
func test_handle_enemy_deaths_all() -> void:
	_enemy_health_component._set_health(0)
	_enemy_2_health_component._set_health(0)
	
	assert_eq(_enemy_list.size(), 2)
	_battler._handle_enemy_deaths()
	assert_eq(_enemy_list.size(), 0)
	assert_true(_enemy.is_queued_for_deletion())
	assert_true(_enemy_2.is_queued_for_deletion())
	await get_tree().process_frame
	assert_false(is_instance_valid(_enemy))
	assert_false(is_instance_valid(_enemy_2))


func test_enemy_death_to_player_attack() -> void:
	_enemy_health_component._set_health(1)
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	
	assert_eq(_enemy_list.size(), 2)
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_list.size(), 1)
	assert_true(_enemy.is_queued_for_deletion())
	await get_tree().process_frame
	assert_false(is_instance_valid(_enemy))


func test_all_enemy_death_to_player_attack_all() -> void:
	_enemy_health_component._set_health(1)
	_enemy_2_health_component._set_health(1)
	var card_damage_all: CardBase = load("res://Cards/Resource/Test Cards/Card_DamageAllEnemies.tres")
	
	assert_eq(_enemy_list.size(), 2)
	card_damage_all.on_card_play(_player, null)
	assert_eq(_enemy_list.size(), 0)
	assert_true(_enemy.is_queued_for_deletion())
	assert_true(_enemy_2.is_queued_for_deletion())
	await get_tree().process_frame
	assert_false(is_instance_valid(_enemy))
	assert_false(is_instance_valid(_enemy_2))



func test_enemy_death_to_poison() -> void:
	_enemy_health_component._set_health(1)
	var card_poison: CardBase = load("res://Cards/Resource/Test Cards/Card_Poison.tres")
	card_poison.on_card_play(_player, _enemy)

	assert_eq(_enemy_list.size(), 2)
	_battler._on_enemy_turn_start()
	assert_eq(_enemy_list.size(), 1)
	assert_true(_enemy.is_queued_for_deletion())
	await get_tree().process_frame
	assert_false(is_instance_valid(_enemy))


func test_enemy_death_to_expiring_poison() -> void:
	_enemy_health_component._set_health(1)
	var card_poison: CardBase = load("res://Cards/Resource/Test Cards/Card_Poison.tres")
	card_poison.on_card_play(_player, _enemy)
	_enemy.get_status_component().current_status[0].status_turn_duration = 1

	assert_eq(_enemy_list.size(), 2)
	assert_eq(_enemy.get_status_component().current_status.size(), 1)
	_battler._on_enemy_turn_start()
	assert_eq(_enemy.get_status_component().current_status.size(), 0)
	assert_eq(_enemy_list.size(), 1)
	assert_true(_enemy.is_queued_for_deletion())
	await get_tree().process_frame
	assert_false(is_instance_valid(_enemy))
	
	
func test_enemy_list_size_enemy_manager() -> void:
	_enemy_health_component._set_health(1)
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	
	assert_eq(_enemy_list.size(), 2)
	assert_eq(EnemyManager.current_enemy_group.enemy_list.size(), 2)
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_list.size(), 1)
	assert_eq(EnemyManager.current_enemy_group.enemy_list.size(), 1)
	assert_true(_enemy.is_queued_for_deletion())
	await get_tree().process_frame
	assert_false(is_instance_valid(_enemy))
