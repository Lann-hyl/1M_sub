extends Node2D
class_name Battler
## Spawns enemies and controls the flow of battle.
## 
## This class holds a list of all the enemies, so it's a good central place to dispatch
## battle actions (player clicking on enemies, enemy attacks, applying status).


@export var enemy_x_spacing: float = 100
@export var enemy_y_spacing: float = -30
@export var enemy_attack_delay: float = 0.3

var _enemy_list: Array[Entity]
var _enemy_action_list: Array[EnemyAction] = []

func _ready() -> void:
	var enemy_group: EnemyGroup = EnemyManager.choose_enemy_group().instantiate()
	add_child(enemy_group)
	_summon_enemies(enemy_group)
	EnemyManager.current_enemy_group.enemy_list = enemy_group.enemy_list
	_enemy_list = enemy_group.enemy_list
	
	# check if our player has been initialized already. If not, wait for the signal
	if (PlayerManager.player == null):
		PlayerManager.on_player_initialized.connect(_on_player_initialized)
	else:
		_on_player_initialized()
	
	PhaseManager.start_combat()
	PhaseManager.on_combat_phase_changed.connect(_on_phase_changed)
	CardManager.on_card_container_initialized.connect(_on_card_container_initialized)
	CardManager.on_card_action_finished.connect(_handle_deaths.unbind(1))


func _summon_enemies(enemy_group: EnemyGroup) -> void:
	EnemyManager.current_enemy_group = enemy_group
	var enemies_to_summon: Array[PackedScene] = enemy_group.enemy_list_packed_scene
	
	for enemy_index: int in enemies_to_summon.size():
		var enemy_instance: Enemy = enemies_to_summon[enemy_index].instantiate()
		add_child(enemy_instance)
		_enemy_list.append(enemy_instance)
		EnemyManager.current_enemy_group.enemy_list.append(enemy_instance)
		enemy_instance.get_click_handler().on_click.connect(_on_enemy_clicked.bind(enemy_instance))
		if enemy_group.positions.size() > enemy_index:
			# if positions are available for that enemy, use it
			enemy_instance.global_position = enemy_group.positions[enemy_index]
		else:
			# otherwise use default
			enemy_instance.global_position.x += enemy_x_spacing * enemy_index
			enemy_instance.global_position.y += enemy_y_spacing * enemy_index
			
	
	# setup party
	for enemy: Entity in _enemy_list:
		enemy.get_party_component().set_party(_enemy_list )


func _on_player_initialized() -> void:
	PlayerManager.player.get_click_handler().on_click.connect(_on_player_clicked)
	PlayerManager.player.get_party_component().add_party_member(PlayerManager.player)
	var list_of_xp_buff: Array[BuffBase] = XpManager.current_list_of_buffs
	var player_status_comp: StatusComponent = PlayerManager.player.get_status_component()
	for buff: BuffBase in list_of_xp_buff:
		player_status_comp.add_status(buff, PlayerManager.player)


func _on_phase_changed(new_phase: GlobalEnums.CombatPhase, _old_phase: GlobalEnums.CombatPhase) -> void:
	match new_phase:
		GlobalEnums.CombatPhase.REMOVE_BLOCK_ALLY:
			_remove_block_ally()
		GlobalEnums.CombatPhase.PLAYER_TURN_START:
			_on_player_turn_start()
		GlobalEnums.CombatPhase.REMOVE_BLOCK_ENEMY:
			_remove_block_all_enemies()
		GlobalEnums.CombatPhase.ENEMY_TURN_START:
			_on_enemy_turn_start()
		GlobalEnums.CombatPhase.ENEMY_ATTACKING:
			_enemy_turn()


func _on_card_container_initialized() -> void:
	if (!CardManager.is_discard_hand_signal_connected(_on_player_hand_discarded)):
		CardManager.connect_discard_hand_signal(_on_player_hand_discarded)


func _on_player_hand_discarded() -> void:
	PhaseManager.advance_to_next_combat_phase()

## Remove the block of all allies (currently just the player) [br]
## Note that later, if we add a status which allows to keep block between turns,
## it should probably be checked here (or maybe in the health component ?)
func _remove_block_ally() -> void:
	PlayerManager.player.get_health_component().reset_block()
	PhaseManager.advance_to_next_combat_phase()

## player start phase: apply status
func _on_player_turn_start() -> void:
	PlayerManager.player.get_status_component().apply_turn_start_status()
	PlayerManager.player.get_energy_component().on_turn_start()
	PhaseManager.advance_to_next_combat_phase()


## Remove the block of all enemies
func _remove_block_all_enemies() -> void:
	for enemy: Entity in _enemy_list:
		enemy.get_health_component().reset_block()
	PhaseManager.advance_to_next_combat_phase()


## enemy start phase: apply status and check death
func _on_enemy_turn_start() -> void:
	# apply status
	for enemy: Entity in _enemy_list:
		enemy.get_stress_component().on_turn_start()
		enemy.get_status_component().apply_turn_start_status()
		
	# if battle have ended, skip the rest of code
	if _handle_deaths():
		return
	else:
		PhaseManager.advance_to_next_combat_phase()
		

## The turn of the enemies, attack player then go the player phase
func _enemy_turn() -> void:
	# generate list of enemy actions
	for enemy: Enemy in _enemy_list:
		var stress_comp: StressComponent = enemy.get_stress_component()
		var enemy_attack: CardBase = enemy.get_behavior_component().get_attack(stress_comp.has_hit_overstress)
		
		var enemy_action: EnemyAction = EnemyAction.new(enemy, enemy_attack, PlayerManager.player)
		_enemy_action_list.append(enemy_action)
	
	# start the attack queue
	assert(_enemy_action_list.size() >= 0, "Enemy tried to attack while there were attacks queued!")
	_handle_enemy_attack_queue()


func _handle_enemy_attack_queue() -> void:
	# don't do anything if there are no attacks in queue
	if _enemy_action_list.is_empty():
		return
		
	var enemy_action: EnemyAction = _enemy_action_list[0]
	_enemy_action_list.remove_at(0)
	
	CardManager.on_card_action_finished.connect(_try_finish_enemy_attacks.unbind(1))
	enemy_action.execute()
	# Potentially reset enemy stress after attack if they were overstressed
	enemy_action.caster.get_stress_component().checked_reset_stress()
		


## Called when an enemy action is finished.
## Tries to queue the next enemy action in the list if it exists.
func _try_finish_enemy_attacks() -> void:
	CardManager.on_card_action_finished.disconnect(_try_finish_enemy_attacks)
	
	await get_tree().create_timer(enemy_attack_delay).timeout
	
	if _enemy_action_list.size() > 0:
		_handle_enemy_attack_queue()
	else:
		PhaseManager.advance_to_next_combat_phase()


## when player clicks themselves (eg: healing card)
func _on_player_clicked() -> void:
	_try_player_play_card_on_entity(PlayerManager.player)


## when player clicks an enemy (eg: damage card)
func _on_enemy_clicked(enemy: Enemy) -> void:
	_try_player_play_card_on_entity(enemy)


func _try_player_play_card_on_entity(entity: Entity) -> void:
	if CardManager.card_container.is_card_queued():
		var queued_card_data: CardBase = CardManager.card_container.queued_card.card_data
		var can_play: bool = queued_card_data.can_play_card(PlayerManager.player, entity)
		
		if can_play:
			CardManager.card_container.play_card(entity)

  
func _handle_enemy_deaths() -> void:
	var enemies_to_remove : Array[Entity] = []
	for enemy: Enemy in _enemy_list:
		if enemy.get_health_component().current_health == 0:
			enemies_to_remove.append(enemy)
			
	for enemy: Enemy in enemies_to_remove:
		_enemy_list.erase(enemy)
		enemy.queue_free()
		
	for enemy: Enemy in _enemy_list:
		enemy.get_party_component().set_party(_enemy_list )


## return TRUE if battle have ended either with victory or defeat
func _check_and_handle_battle_end() -> bool:
	if PlayerManager.player.get_health_component().current_health <= 0:
		PhaseManager.on_defeat.emit()
		return true
	if _enemy_list.is_empty():
		PhaseManager.on_event_win.emit()
		return true
	
	return false    


## return TRUE if battle have ended
func _handle_deaths() -> bool:
	_handle_enemy_deaths()
	return _check_and_handle_battle_end()


# TODO reset temporary stats at the end of the combat using EntityStats.reset_modifier_dict_temp_to_default()
