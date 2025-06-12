extends TestBase
## Test for the energy system

var card: CardBase

# @overide
func before_each() -> void:
	super()
	_player_energy_component.ignore_cost = false
	_player_energy_component.energy = 0
	_player_energy_component.energy_generation = 3
	_player_energy_component.MAX_ENERGY = 4

func test_add_energy() -> void:
	card = load("res://Cards/Resource/Test Cards/Card_Energy.tres") # adds 70 energy
	card.energy_info.energy_cost = 0
	card.on_card_play(_player, _player)
	assert_eq(_player_energy_component.energy, 70)

func test_using_energy() -> void:
	_player_energy_component.add_energy(10)
	card = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card.energy_info.energy_cost = 7

	card.on_card_play(PlayerManager.player, _enemy)

	assert_eq(_player_energy_component.energy, 3)

func test_play_card_with_not_enough_energy() -> void:

	_card_container.draw_cards(1)
	
	var card_to_queue: CardWorld = _card_container.cards_in_hand[0]
	card_to_queue.card_data.energy_info.energy_cost = 999

	_card_container._on_card_clicked(card_to_queue)

	assert_eq(_player_energy_component.energy, 0)
	assert_false(_card_container.is_card_queued())

func test_almost_enough_energy() -> void:

	_card_container.draw_cards(1)
	_player_energy_component.add_energy(4)
	var card_to_queue: CardWorld = _card_container.cards_in_hand[0]

	card_to_queue.card_data.energy_info.energy_cost = 5

	_card_container._on_card_clicked(card_to_queue)

	assert_eq(_player_energy_component.energy, 4)
	assert_false(_card_container.is_card_queued())

func test_play_card_with_enough_energy() -> void:

	_player_energy_component.add_energy(10)
	_card_container.draw_cards(1)

	var card_to_queue: CardWorld = _card_container.cards_in_hand[0]
	card_to_queue.card_data.energy_info.energy_cost = 9

	_card_container._on_card_clicked(card_to_queue)

	assert_true(_card_container.is_card_queued())

func test_play_card_with_just_enough_energy() -> void:

	_player_energy_component.add_energy(3)
	_card_container.draw_cards(1)

	var _queued_card: CardWorld = _card_container.cards_in_hand[0]
	_queued_card.card_data.energy_info.energy_cost = 3

	_card_container._on_card_clicked(_queued_card)

	assert_true(_card_container.is_card_queued())

func test_energy_generation() -> void:

	assert_eq(_player_energy_component.energy, 0)
	_player_energy_component.on_turn_start()

	assert_eq(_player_energy_component.energy, 3)
	_player_energy_component.on_turn_start()

	assert_eq(_player_energy_component.energy, 4)
