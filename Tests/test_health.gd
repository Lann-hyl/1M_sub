extends TestBase
## Tests for health related things (dealing, taking damage, status dealing damage, etc...)


func test_take_damage() -> void:
	var damage: int = 5
	var caster: Entity = _player

	_player_health_component.take_damage_block_and_health(damage, caster)
	assert_eq(_player_health_component.current_health, 95)

func test_take_damage_with_block() -> void:
	var damage: int = 10
	var caster: Entity = _player
	
	_player_health_component.add_block(5, caster)
	_player_health_component.take_damage_block_and_health(damage, caster)
	assert_eq(_player_health_component.current_health, 95)

func test_add_block() -> void:
	var amount: int = 10
	var caster: Entity = _player
	
	_player_health_component.add_block(amount, caster)
	assert_eq(_player_health_component.current_block, amount)

func test_take_damage_to_block() -> void:
	var damage : int = 5
	var block_amount: int = 10
	var caster: Entity = _player
	
	_player_health_component._set_health(100)
	_player_health_component.add_block(block_amount, caster)
	_player_health_component.take_damage_block_and_health(damage, caster)
	assert_eq(_player_health_component.current_block, 5)
	assert_eq(_player_health_component.current_health, 100)

## might remove in future if emiting signal gets complicated
func test_reset_block_on_round_start() -> void: 
	var block_amount: int = 10
	var caster: Entity = _player
	
	_player_health_component.add_block(block_amount, caster)
	PhaseManager._set_combat_phase(GlobalEnums.CombatPhase.REMOVE_BLOCK_ALLY)
	PhaseManager.current_combat_phase_index = 0
	#PhaseManager.on_combat_phase_changed.emit(GlobalEnums.CombatPhase.REMOVE_BLOCK_ALLY, GlobalEnums.CombatPhase.ENEMY_ATTACKING)
	assert_eq(_player_health_component.current_block, 0)

func test_take_lots_of_damage() -> void:
	var damage: int = 999999
	var caster: Entity = _player

	_player_health_component.take_damage_block_and_health(damage, caster)
	assert_eq(_player_health_component.current_health, 0)


func test_null_caster() -> void:
	var damage: int = 50
	var caster: Entity = null

	_player_health_component.take_damage_block_and_health(damage, caster)
	assert_eq(_player_health_component.current_health, 50)


func test_heal() -> void:
	var heal: int = 50
	var caster: Entity = _player

	_player_health_component._set_health(50)
	_player_health_component.heal(heal, caster)
	assert_eq(_player_health_component.current_health, 100)


func test_attack_enemy() -> void:
	var damage: int = 50
	var caster: Entity = _player

	_enemy_health_component.take_damage_block_and_health(damage, caster)
	assert_eq(_enemy_health_component.current_health, 50)


func test_poison_status() -> void:
	var poison_status: StatusBase = Debuff_Poison.new()
	poison_status.status_power = 1
	poison_status.status_turn_duration = 3
	poison_status.status_target = _enemy
	poison_status.status_caster = _player
	_enemy_status_component.add_status(poison_status, _player)

	poison_status.on_turn_start()
	assert_eq(_enemy_health_component.current_health, 99)


# Test Card to Deal 2 damage to all enemies
func test_card_damage_all() -> void:
	_enemy.get_party_component().set_party(_enemy_list )
	var card_damage_all: CardBase = load("res://Cards/Resource/Test Cards/Card_DamageAllEnemies.tres")
	
	card_damage_all.on_card_play(_player, null)

	assert_eq(_enemy_health_component.current_health, 98)
	assert_eq(_enemy_2_health_component.current_health, 48)  # enemy 2 only has 50 HP


# Test Card to Deal 3 damage to an enemy
func test_card_damage() -> void:
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")

	card_damage.on_card_play(_player, _enemy)
	
	assert_eq(_enemy_health_component.current_health, 97)


# Test Card to deal damage to enemy based on amount of player health lost
func test_card_damage_health() -> void:
	_player.get_health_component()._set_health(90)
	var card_damage_health: CardBase = load("res://Cards/Resource/Test Cards/Card_DamageHealth.tres")

	card_damage_health.on_card_play(_player, _enemy)
	
	assert_eq(_enemy_health_component.current_health, 90)


# Test Card that applies 3 poison to enemy and does poison damage on enemy turn
func test_card_poison() -> void:
	var card_poison: CardBase = load("res://Cards/Resource/Test Cards/Card_Poison.tres")

	assert_eq(_enemy_status_component.current_status.size(), 0)
	card_poison.on_card_play(_player, _enemy)
	assert_eq(_enemy_status_component.current_status.size(), 1)

	var status: StatusBase = _enemy_status_component.current_status[0]
	assert_is(status, Debuff_Poison)
	assert_eq(status.status_turn_duration, 3)

	_enemy_status_component.apply_turn_start_status()
	# May need to update once we have a better direction of what to do for poison, currently
	# it deals only 1 damage per turn
	assert_eq(_enemy_health_component.current_health, 99)


# Test Card that deals 1 damage and applies 2 poison to enemy and does poison damage on enemy turn
func test_card_damage_and_poison() -> void:
	var card_damage_and_poison: CardBase = load("res://Cards/Resource/Test Cards/Card_damage_and_poison.tres")

	assert_eq(_enemy_status_component.current_status.size(), 0)
	card_damage_and_poison.on_card_play(_player, _enemy)
	assert_eq(_enemy_status_component.current_status.size(), 1)
	assert_eq(_enemy_health_component.current_health, 99)

	var status: StatusBase = _enemy_status_component.current_status[0]
	assert_is(status, Debuff_Poison)
	assert_eq(status.status_turn_duration, 2)

	_enemy_status_component.apply_turn_start_status()
	# May need to update once we have a better direction of what to do for poison, currently
	# it deals only 1 damage per turn
	assert_eq(_enemy_health_component.current_health, 98)


# Test Card that heals one HP to player
func test_card_heal() -> void:
	var card_heal: CardBase = load("res://Cards/Resource/Test Cards/Card_Heal.tres")
	_player_health_component._set_health(95)

	card_heal.on_card_play(_player, _player)
	
	assert_eq(_player_health_component.current_health, 96)

func test_card_heal_with_strength_buff() -> void:
	var card_heal: CardBase = load("res://Cards/Resource/Test Cards/Card_Heal.tres")
	var buff: CardBase = load("res://Cards/Resource/Test Cards/Card_Strength.tres")
	StatModifiers.ready_card_modifier(buff)

	_player_health_component._set_health(90)

	buff.on_card_play(_player, _player)
	card_heal.on_card_play(_player, _player)
	
	assert_eq(_player_health_component.current_health, 91)

func test_card_heal_with_heal_buff() -> void:
	var card_heal: CardBase = load("res://Cards/Resource/Test Cards/Card_Heal.tres")
	var buff: CardBase = load("res://Cards/Resource/Test Cards/Card_Buff_healing.tres")
	StatModifiers.ready_card_modifier(buff)

	_player_health_component._set_health(90)

	buff.on_card_play(_player, _player)
	
	card_heal.on_card_play(_player, _player)

	assert_eq(_player_health_component.current_health, 92)


func test_card_heal_with_heal_debuff() -> void:
	var card_heal: CardBase = load("res://Cards/Resource/Test Cards/Card_Heal.tres")
	var debuff: CardBase = load("res://Cards/Resource/Test Cards/Card_Debuff_healing.tres")
	StatModifiers.ready_card_modifier(debuff)

	_player_health_component._set_health(90)

	debuff.on_card_play(_player, _player)
	
	card_heal.on_card_play(_player, _player)

	assert_eq(_player_health_component.current_health, 90)

# Test card that deals 10 damage to every entity (player and enemies)
func test_card_damage_everything() -> void:
	var card_damage_everything: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage_EVERYTHING.tres")
	card_damage_everything.on_card_play(_player, null)
	
	assert_eq(_player_health_component.current_health, 90)
	assert_eq(_enemy_health_component.current_health, 90)
	assert_eq(_enemy_2_health_component.current_health, 40)
	

#Apply 3 poison effect randomly, each with 3 turns
func test_card_random_poison() -> void:
	var card_random_poison: CardBase = load("res://Cards/Resource/Test Cards/Card_PoisonRandom.tres")
	
	card_random_poison.on_card_play(_player, null)
	
	var poison_effect_turn_enemy_1 : int
	var poison_effect_turn_enemy_2 : int
	if _enemy_status_component.current_status.size() >= 1:
		poison_effect_turn_enemy_1 = _enemy_status_component.current_status[0].status_turn_duration
	if _enemy_2_status_component.current_status.size() >= 1:
		poison_effect_turn_enemy_2 = _enemy_2_status_component.current_status[0].status_turn_duration
	var total_turn_duration : int = poison_effect_turn_enemy_1 + poison_effect_turn_enemy_2
	
	assert_eq(total_turn_duration, 9)


# Deal 6 damage to all enemies
func test_card_sweep() -> void:
	var card_fauna_sweep: CardBase = load("res://Cards/Resource/Card_Sweep.tres")
	
	card_fauna_sweep.on_card_play(_player, _enemy)
	
	assert_eq(_enemy_health_component.current_health, 94)
	assert_eq(_enemy_2_health_component.current_health, 44)
	
	card_fauna_sweep.on_card_play(_player, _enemy_2)
	
	assert_eq(_enemy_health_component.current_health, 88) 
	# Enemy 1 is on the left, we target enemy_2 so enemy 1 not affected
	assert_eq(_enemy_2_health_component.current_health, 38)
