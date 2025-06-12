extends TestBase
## Test that the data of the player stays between fights


func _create_player() -> void:
	_player = _player_scene.instantiate()
	get_tree().root.add_child(_player)
	
	_player_health_component = _player.get_health_component()
	_player_stat_component = _player.get_stat_component()
	_player_energy_component = _player.get_energy_component()
	
	_player_energy_component.ignore_cost = true
	
	# NOTE: This resets the stats, so we don't want to call it when we're creating a player
	# for persistence testing.
	#_player_stat_component.stats.ready_entity_stats()


func test_persist_player_health() -> void:
	_player_health_component.take_damage_block_and_health(5, _player)
	
	assert_eq(_player_health_component.current_health, 95)
	
	_player._should_save_persistent_data = true
	
	_player.free()
	_create_player()
	
	assert_eq(_player_health_component.current_health, 95)


func test_persist_strength_status() -> void:
	var strength_status: Buff_Strength = Buff_Strength.new()
	
	var stat_modifer: StatModifiers = StatModifiers.new()
	stat_modifer.permanent_add = 2
	stat_modifer.ready()
	strength_status.status_modifier_base_value = stat_modifer
	_player.get_status_component().add_status(strength_status, _player)
	
	var card_damage: CardBase = load("res://Cards/Resource/Test Cards/Card_Damage.tres")
	card_damage.card_effects_data[0].value = 2
	card_damage.on_card_play(_player, _enemy)
	assert_eq(_enemy_health_component.current_health, 96)
	
	_player._should_save_persistent_data = true
	
	_player.free()
	_create_player()
	
	# player should still have their permanent buff after being destroyed and recreated
	card_damage.on_card_play(_player, _enemy_2) # enemy 2 has 50 health
	assert_eq(_enemy_2_health_component.current_health, 46)


func test_persist_cards() -> void:
	CardManager.current_deck.clear()
	CardManager.current_deck.append(CardBase.new())
	CardManager.current_deck.append(CardBase.new())
	CardManager.current_deck[0].card_title = "Card0"
	CardManager.current_deck[1].card_title = "Card1"
	
	assert_eq(CardManager.current_deck.size(), 2)
	
	# Destroy the container
	_card_container.free()
	
	# Modify the deck
	CardManager.current_deck.clear()
	CardManager.current_deck.append(CardBase.new())
	CardManager.current_deck[0].card_title = "Card2"
	
	# Recreate the container
	_card_container = _card_container_scene.instantiate()
	get_tree().root.add_child(_card_container)
	
	# Make sure the data was loaded into the container
	assert_eq(CardManager.current_deck.size(), 1)
	assert_eq(_card_container.draw_pile.size(), 1)
	assert_eq(_card_container.draw_pile[0].card_title, "Card2")
