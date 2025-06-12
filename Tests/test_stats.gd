extends TestBase
## Test the stats


func test_possible_modifier_size() -> void:
	var expected_size: int = 7
	var actual_size: int = GlobalEnums.PossibleModifierNames.size()
	assert_eq(actual_size, expected_size, "Expected %s possible modifiers but got %s instead" % [expected_size, actual_size])


func test_offense_dict_size() -> void:
	var offense_dict_size_player: int = _player_stat_component.stats._offense_modifier_dict.stat_dict.size()
	var offense_dict_size_enemy: int = _enemy_stat_component.stats._offense_modifier_dict.stat_dict.size()
	var modifier_dict_size: int = GlobalEnums.PossibleModifierNames.size()
	var assert_false_string: String = "Expected offense_dict_size to be %s (PossibleModifierNames.size()) but got %s instead for entity %s"
	assert_eq(offense_dict_size_player, modifier_dict_size, assert_false_string % [modifier_dict_size, offense_dict_size_player, "player"])
	assert_eq(offense_dict_size_enemy, modifier_dict_size, assert_false_string % [modifier_dict_size, offense_dict_size_enemy, "enemy"])


func test_defense_dict_size() -> void:
	var defense_dict_size_player: int = _player_stat_component.stats._defense_modifier_dict.stat_dict.size()
	var defense_dict_size_enemy: int = _enemy_stat_component.stats._defense_modifier_dict.stat_dict.size()
	var modifier_dict_size: int = GlobalEnums.PossibleModifierNames.size()
	var assert_false_string: String = "Expected defense_dict_size to be %s (PossibleModifierNames.size()) but got %s instead for entity %s"
	assert_eq(defense_dict_size_player, modifier_dict_size, assert_false_string % [modifier_dict_size, defense_dict_size_player, "player"])
	assert_eq(defense_dict_size_enemy, modifier_dict_size, assert_false_string % [modifier_dict_size, defense_dict_size_enemy, "enemy"])


# apply strength to player and damage enemy
func test_strength_status() -> void:
	var strength_status: Buff_Strength = Buff_Strength.new()
	# add 1 damage offense on the player
	var stat_modifer: StatModifiers = StatModifiers.new()
	stat_modifer.temporary_add = 1
	stat_modifer.ready()
	strength_status.status_modifier_base_value = stat_modifer
	_player.get_status_component().add_status(strength_status, _player)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.card_effects_data[0].value = 50 # modified for the test
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 49)
	

func test_strength_card() -> void:
	var card_strength: CardBase = load("res://Cards/Resource/Test Cards/Card_Strength.tres")
	StatModifiers.ready_card_modifier(card_strength) 
	card_strength.on_card_play(_player, _player)
	
	assert_is(_player.get_status_component().current_status[0], Buff_Strength)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.card_effects_data[0].value = 3
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 96)
	

# apply weakness to player and damage enemy
func test_weakness_status() -> void:
	var weakness_status: Debuff_Weakness = Debuff_Weakness.new()
	# remove 1 damage offense on the player
	var stat_modifer: StatModifiers = StatModifiers.new()
	stat_modifer.temporary_add = -1
	stat_modifer.ready()
	weakness_status.status_modifier_base_value = stat_modifer
	_player.get_status_component().add_status(weakness_status, _player)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.card_effects_data[0].value = 50 # modified for the test
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 51)
	

func test_weakness_card() -> void:
	var card_weakness: CardBase = load("res://Cards/Resource/Test Cards/Card_Weakness.tres")
	StatModifiers.ready_card_modifier(card_weakness) 
	card_weakness.on_card_play(_player, _player)
	
	assert_is(_player.get_status_component().current_status[0], Debuff_Weakness)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.card_effects_data[0].value = 3
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 98)


# apply vulnerability to enemy and damage enemy
func test_vulnerability_status() -> void:
	var vulnerability_status: Debuff_Vulnerability = Debuff_Vulnerability.new()
	# remove 1 damage defense on the enemy
	var stat_modifer: StatModifiers = StatModifiers.new()
	stat_modifer.temporary_add = -1
	stat_modifer.ready()
	vulnerability_status.status_modifier_base_value = stat_modifer
	
	_enemy.get_status_component().add_status(vulnerability_status, _player)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.card_effects_data[0].value = 50 # modified for the test
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 49)
	

func test_vulnerability_card() -> void:
	var card_vulnerability: CardBase = load("res://Cards/Resource/Test Cards/Card_Vulnerability.tres")
	StatModifiers.ready_card_modifier(card_vulnerability) 
	card_vulnerability.on_card_play(_player, _enemy)
	
	assert_is(_enemy.get_status_component().current_status[0], Debuff_Vulnerability)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.card_effects_data[0].value = 3
	# due to the caching of Card_Damage.tres because we modified the value to be 50 in a previous test we modify it back to 3
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 96)


func test_multiple_status_modifying_stats() -> void:
	var strength_status: Buff_Strength = Buff_Strength.new()
	# add 1 damage offense on the player
	var stat_modifer_strength: StatModifiers = StatModifiers.new()
	stat_modifer_strength.temporary_add = 1
	stat_modifer_strength.ready()
	strength_status.status_modifier_base_value = stat_modifer_strength
	_player.get_status_component().add_status(strength_status, _player)
	
	var weakness_status: Debuff_Weakness = Debuff_Weakness.new()
	# remove 1 damage offense on the player
	var stat_modifer_weakness: StatModifiers = StatModifiers.new()
	stat_modifer_weakness.temporary_add = -1
	stat_modifer_weakness.ready()
	weakness_status.status_modifier_base_value = stat_modifer_weakness
	_player.get_status_component().add_status(weakness_status, _player)
	
	var vulnerability_status: Debuff_Vulnerability = Debuff_Vulnerability.new()
	# remove 1 damage defense on the enemy
	var stat_modifer_vuln: StatModifiers = StatModifiers.new()
	stat_modifer_vuln.temporary_add = -1
	stat_modifer_vuln.ready()
	vulnerability_status.status_modifier_base_value = stat_modifer_vuln
	_enemy.get_status_component().add_status(vulnerability_status, _player)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.card_effects_data[0].value = 50 # modified for the test
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 49)
	# final health is 49 because original is 100, we do 50 damage
	# we add 1 damage because of strength, remove 1 because of weakness
	# and add 1 because of vulnerability (remove 1 defense on the enemy)
	
	
func test_strength_multiplier() -> void:
	var strength_status: Buff_Strength = Buff_Strength.new()
	# add 1 damage offense on the player
	var stat_modifer: StatModifiers = StatModifiers.new()
	stat_modifer.temporary_multiply= 1.5
	stat_modifer.ready()
	strength_status.status_modifier_base_value = stat_modifer
	_player.get_status_component().add_status(strength_status, _player)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.card_effects_data[0].value = 50 # modified for the test
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 25)
	# 100 (base health) - (50 (base damage) * 1.5 (strength multiplier))


func test_remove_strength() -> void:
	var strength_status: Buff_Strength = Buff_Strength.new()
	# add 1 damage offense on the player
	var stat_modifer: StatModifiers = StatModifiers.new()
	stat_modifer.temporary_add = 1
	stat_modifer.ready()
	strength_status.status_modifier_base_value = stat_modifer
	_player.get_status_component().add_status(strength_status, _player)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.card_effects_data[0].value = 3
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 96) 
	# 100 (base health) - (3 (base damage) + 1 (strength))
	
	_player.get_status_component().remove_status(strength_status)
	assert_eq(_player.get_status_component().current_status.size(), 0)
	
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 93)
	# 96 (previous health) - 3 (base damage)
	# we don't have the strength bonus of +1 damage anymore


func test_remove_weakness() -> void:
	var weakness_status: Debuff_Weakness = Debuff_Weakness.new()
	# remove 1 damage offense on the player
	var stat_modifer: StatModifiers = StatModifiers.new()
	stat_modifer.temporary_add = -1
	stat_modifer.ready()
	weakness_status.status_modifier_base_value = stat_modifer
	_player.get_status_component().add_status(weakness_status, _player)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 98)
	# 100 (base health) - (3 (base damage) - 1 (weakness))
	
	_player.get_status_component().remove_status(weakness_status)
	assert_eq(_player.get_status_component().current_status.size(), 0)
	
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 95)
	# 98 (previous health) - 3 (base damage)
	# we don't have the weakness malus of -1 damage anymore


func test_remove_vulnerability() -> void:
	var vulnerability_status: Debuff_Vulnerability = Debuff_Vulnerability.new()
	# remove 1 damage defense on the enemy
	var stat_modifer: StatModifiers = StatModifiers.new()
	stat_modifer.temporary_add = -1
	stat_modifer.ready()
	vulnerability_status.status_modifier_base_value = stat_modifer
	_enemy.get_status_component().add_status(vulnerability_status, _player)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 96)
	# 100 (base health) - (3 (base damage) + 1 (vulnerability))
	
	_enemy.get_status_component().remove_status(vulnerability_status)
	assert_eq(_enemy.get_status_component().current_status.size(), 0)
	
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 93)
	# 96 (previous health) - 3 (base damage)
	# enemy doesn't have the vulnerability malus of -1 defense anymore


func test_remove_multiple_status() -> void:
	var strength_status: Buff_Strength = Buff_Strength.new()
	# add 1 damage offense on the player
	var stat_modifer_strength: StatModifiers = StatModifiers.new()
	stat_modifer_strength.temporary_add = 1
	stat_modifer_strength.ready()
	strength_status.status_modifier_base_value = stat_modifer_strength
	_player.get_status_component().add_status(strength_status, _player)
	
	var weakness_status: Debuff_Weakness = Debuff_Weakness.new()
	# remove 1 damage offense on the player
	var stat_modifer_weakness: StatModifiers = StatModifiers.new()
	stat_modifer_weakness.temporary_add = -1
	stat_modifer_weakness.ready()
	weakness_status.status_modifier_base_value = stat_modifer_weakness
	_player.get_status_component().add_status(weakness_status, _player)
	
	var vulnerability_status: Debuff_Vulnerability = Debuff_Vulnerability.new()
	# remove 1 damage defense on the enemy
	var stat_modifer_vuln: StatModifiers = StatModifiers.new()
	stat_modifer_vuln.temporary_add = -1
	stat_modifer_vuln.ready()
	vulnerability_status.status_modifier_base_value = stat_modifer_vuln
	_enemy.get_status_component().add_status(vulnerability_status, _player)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 96)
	# final health : 100 (base health) - (3 (base damage) + 1 (strength) - 1 (weakness) + 1 (vulnerability))
	# = 96
	
	_player.get_status_component().remove_all_status()
	_enemy.get_status_component().remove_all_status()
	assert_eq(_player.get_status_component().current_status.size(), 0)
	assert_eq(_enemy.get_status_component().current_status.size(), 0)
	
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 93)
	# 96 (previous health) - 3 (base damage)
	
	
func test_reset_modifier_dict_temp_to_default() -> void:
	var strength_status: Buff_Strength = Buff_Strength.new()
	# add 1 damage offense on the player
	var stat_modifer_strength: StatModifiers = StatModifiers.new()
	stat_modifer_strength.temporary_add = 1
	stat_modifer_strength.ready()
	strength_status.status_modifier_base_value = stat_modifer_strength
	_player.get_status_component().add_status(strength_status, _player)
	
	var weakness_status: Debuff_Weakness = Debuff_Weakness.new()
	# remove 1 damage offense on the player
	var stat_modifer_weakness: StatModifiers = StatModifiers.new()
	stat_modifer_weakness.temporary_add = -1
	stat_modifer_weakness.ready()
	weakness_status.status_modifier_base_value = stat_modifer_weakness
	_player.get_status_component().add_status(weakness_status, _player)
	
	var vulnerability_status: Debuff_Vulnerability = Debuff_Vulnerability.new()
	# remove 1 damage defense on the enemy
	var stat_modifer_vuln: StatModifiers = StatModifiers.new()
	stat_modifer_vuln.temporary_add = -1
	stat_modifer_vuln.ready()
	vulnerability_status.status_modifier_base_value = stat_modifer_vuln
	_enemy.get_status_component().add_status(vulnerability_status, _player)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 96)
	# final health : 100 (base health) - (3 (base damage) + 1 (strength) - 1 (weakness) + 1 (vulnerability))
	# = 96
	
	_player_stat_component.stats.reset_modifier_dict_temp_to_default()
	_enemy_stat_component.stats.reset_modifier_dict_temp_to_default()
	
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 93)
	# 96 (previous health) - 3 (base damage)
	

func test_remove_strength_multiplier() -> void:
	var strength_status: Buff_Strength = Buff_Strength.new()
	# multiply offense damage by 1.5 from the player
	var stat_modifer: StatModifiers = StatModifiers.new()
	stat_modifer.temporary_multiply = 1.5
	stat_modifer.ready()
	strength_status.status_modifier_base_value = stat_modifer
	_player.get_status_component().add_status(strength_status, _player)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.card_effects_data[0].value = 10 # modified for the test
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 85)
	# 100 (base health) - (10 (base damage) * 1.5 (strength multiplier))
	
	_player.get_status_component().remove_status(strength_status)
	assert_eq(_player.get_status_component().current_status.size(), 0)
	
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 75)
	# 85 (previous health) - 10 (base damage)
	# we don't have the strength multiplier of *1.5 anymore


func test_buff_poison_duration_status() -> void:
	var buff_poison_duration: StatusBase = Buff_Poison_Duration.new()
	var stat_modifer: StatModifiers = StatModifiers.new()
	stat_modifer.temporary_add = 1
	stat_modifer.ready()
	buff_poison_duration.status_modifier_base_value = stat_modifer
	_player.get_status_component().add_status(buff_poison_duration, _player)
	
	var debuff_poison: StatusBase = Debuff_Poison.new()
	_enemy.get_status_component().add_status(debuff_poison, _player)
	
	assert_eq(_enemy.get_status_component().current_status.size(), 1)
	assert_eq(_enemy.get_status_component().current_status[0].status_turn_duration, 4)
	# base value is 3, +1 because of buff_poison_duration
	
	
func test_buff_poison_duration_card() -> void:
	var card_buff_poison_duration: CardBase = load("res://Cards/Resource/Test Cards/Card_Buff_Poison_Duration.tres")
	# buff duration by 2
	StatModifiers.ready_card_modifier(card_buff_poison_duration) 
	card_buff_poison_duration.on_card_play(_player, _player)
	
	assert_is(_player.get_status_component().current_status[0], Buff_Poison_Duration)
	
	var card_poison: CardBase = load("res://Cards/Resource/Test Cards/Card_Poison.tres")
	card_poison.on_card_play(_player, _enemy)
	assert_eq(_enemy.get_status_component().current_status.size(), 1)
	assert_eq(_enemy.get_status_component().current_status[0].status_turn_duration, 5)
	# base value is 3, +2 because of buff_poison_duration


func test_buff_poison_duration_multiple_times() -> void:
	var buff_poison_duration: StatusBase = Buff_Poison_Duration.new()
	var stat_modifer: StatModifiers = StatModifiers.new()
	stat_modifer.temporary_add = 1
	stat_modifer.ready()
	buff_poison_duration.status_modifier_base_value = stat_modifer
	_player.get_status_component().add_status(buff_poison_duration, _player)
	
	var debuff_poison: StatusBase = Debuff_Poison.new()
	_enemy.get_status_component().add_status(debuff_poison, _player)
	_enemy.get_status_component().add_status(debuff_poison, _player)
	
	assert_eq(_enemy.get_status_component().current_status.size(), 1)
	assert_eq(_enemy.get_status_component().current_status[0].status_turn_duration, 8)
	# base value is 3, +1 because of buff_poison_duration, *2 because of 2 debuff_poison


func test_buff_poison_duration_removal() -> void:
	var buff_poison_duration: StatusBase = Buff_Poison_Duration.new()
	var stat_modifer: StatModifiers = StatModifiers.new()
	stat_modifer.temporary_add = 1
	stat_modifer.ready()
	buff_poison_duration.status_modifier_base_value = stat_modifer
	_player.get_status_component().add_status(buff_poison_duration, _player)
	
	var debuff_poison: StatusBase = Debuff_Poison.new()
	_enemy.get_status_component().add_status(debuff_poison, _player)
	_player.get_status_component().remove_status(buff_poison_duration)
	_enemy.get_status_component().add_status(debuff_poison, _player)
	
	assert_eq(_enemy.get_status_component().current_status.size(), 1)
	assert_eq(_enemy.get_status_component().current_status[0].status_turn_duration, 7)
	# base value is 3, +1 because of buff_poison_duration, and +3 because applied again without duration buff
	
