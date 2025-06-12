extends TestBase
## Test the stress mechanic

var _enemy_behavior_component: BehaviorComponent = null

func before_each() -> void:
	super()
	_enemy_behavior_component = _enemy.get_behavior_component()

func test_stress_generation() -> void:
	var previous_stress: int = _enemy_stress_component.current_stress
	var stress_generation: int = 5
	_enemy_stress_component.stress_generation = stress_generation
	_enemy_stress_component.on_turn_start()
	assert_eq(_enemy_stress_component.current_stress - previous_stress, stress_generation)

	
func test_stress_card() -> void:
	var previous_stress: int = _enemy_stress_component.current_stress
	var card_stress: CardBase = load("res://Cards/Resource/Test Cards/Card_Stress_Damage.tres")
	card_stress.on_card_play(_player, _enemy)
	assert_eq(_enemy_stress_component.current_stress, previous_stress + 10)
	
	
func test_sooth_card() -> void:
	var previous_stress: int = _enemy_stress_component.current_stress
	var card_sooth: CardBase = load("res://Cards/Resource/Card_HeartHands.tres")
	card_sooth.on_card_play(_player, _enemy)
	assert_eq(_enemy_stress_component.current_stress, previous_stress - 8)
	
	
func test_sooth_buff() -> void:
	var previous_stress: int = _enemy_stress_component.current_stress
	var buff_sooth: CardBase = load("res://Cards/Resource/Test Cards/Card_buff_sooth.tres")
	StatModifiers.ready_card_modifier(buff_sooth)
	buff_sooth.on_card_play(_player, _player)
	var card_sooth: CardBase = load("res://Cards/Resource/Card_HeartHands.tres")
	card_sooth.on_card_play(_player, _enemy)
	assert_eq(_enemy_stress_component.current_stress, previous_stress - 9)
	
	
func test_sooth_debuff() -> void:
	var previous_stress: int = _enemy_stress_component.current_stress
	var debuff_sooth: CardBase = load("res://Cards/Resource/Test Cards/Card_debuff_sooth.tres")
	StatModifiers.ready_card_modifier(debuff_sooth)
	debuff_sooth.on_card_play(_player, _player)
	var card_sooth: CardBase = load("res://Cards/Resource/Card_HeartHands.tres")
	card_sooth.on_card_play(_player, _enemy)
	assert_eq(_enemy_stress_component.current_stress, previous_stress - 7)
	

func test_enemy_stays_soothed() -> void:
	_enemy_stress_component.current_stress = 2
	var card_sooth: CardBase = load("res://Cards/Resource/Card_HeartHands.tres")
	card_sooth.on_card_play(_player, _enemy)
	assert_eq(_enemy_stress_component.current_stress, 0)
	_enemy_stress_component.on_turn_start()
	assert_eq(_enemy_stress_component.current_stress, 0)
	
	
func test_enemy_overstress() -> void:
	_enemy_stress_component.current_stress = 75 # max stress is 80
	var card_stress: CardBase = load("res://Cards/Resource/Test Cards/Card_Stress_Damage.tres")
	card_stress.on_card_play(_player, _enemy)
	assert_eq(_enemy_stress_component.current_stress, 80)
	assert_true(_enemy_stress_component.has_hit_overstress)
	var expected_damage_val: int = StressComponent.on_overstress().card_effects_data[0].value
	var actual_damage_val: int = _enemy_behavior_component.get_attack(_enemy_stress_component.has_hit_overstress).card_effects_data[0].value
	assert_eq(actual_damage_val, expected_damage_val)
