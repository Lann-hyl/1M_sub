class_name TestBase extends GutTest
## Common test setup to be used by other tests

## The data of the player
var _player_scene: PackedScene = load("res://Entity/Player/Player.tscn")
## Battler scene
var _battler_scene: PackedScene = load("res://Core/Battler.tscn")
## Card container scene
var _card_container_scene: PackedScene = load("res://Cards/CardContainer.tscn")
## Player entity
var _player: Player = null
## Enemy entity
var _enemy: Entity = null
## Enemy 2 entity
var _enemy_2: Entity = null
## The battler node
var _battler: Battler = null
## The card container node
var _card_container: CardContainer = null
## Player energy component
var _player_energy_component: EnergyComponent = null
## Player health component
var _player_health_component: HealthComponent = null
## Enemy health component
var _enemy_health_component: HealthComponent = null
## Enemy 2 health component
var _enemy_2_health_component: HealthComponent = null
## Player stat component
var _player_stat_component: StatComponent = null
## Enemy stat component
var _enemy_stat_component: StatComponent = null
## Enemy 2 stat component
var _enemy_2_stat_component: StatComponent = null
## Enemy stress component
var _enemy_stress_component: StressComponent = null
## Enemy 2 stress component
var _enemy_2_stress_component: StressComponent = null
## Player status component
var _player_status_component: StatusComponent = null
## Enemy status component
var _enemy_status_component: StatusComponent = null
## Enemy 2 status component
var _enemy_2_status_component: StatusComponent = null
## The list of the enemies
var _enemy_list: Array[Entity]


## Setup the environment before each test [br]
## To be overidden by child tests if they want to do something more or something else [br]
## Child tests that just want to add some stuff can call super to do the initial setup, then their own setup
func before_each() -> void:
	DebugVar.DEBUG_USE_TEST_ENEMY_GROUP = true
	# Init the player, battler, and card container
	_player = _player_scene.instantiate()
	_battler = _battler_scene.instantiate()
	_card_container = _card_container_scene.instantiate()
	
	# Add the init instances to the tree
	get_tree().root.add_child(_player)
	get_tree().root.add_child(_battler)
	get_tree().root.add_child(_card_container)
	
	_enemy_list = _battler._enemy_list
	
	# Setup enemy list
	_enemy = _enemy_list[0] # enemy 1 has 100 HP
	_enemy_2 = _enemy_list[1] # enemy 2 50 HP
	
	# Setup all the components
	_player_energy_component = _player.get_energy_component()
	_player_health_component = _player.get_health_component()
	_enemy_health_component = _enemy.get_health_component()
	_player_stat_component = _player.get_stat_component()
	_enemy_stat_component = _enemy.get_stat_component()
	_enemy_2_stat_component = _enemy_2.get_stat_component()
	_enemy_stress_component = _enemy.get_stress_component()
	_enemy_2_stress_component = _enemy_2.get_stress_component()
	_enemy_2_health_component = _enemy_2.get_health_component()
	_player_status_component = _player.get_status_component()
	_enemy_status_component = _enemy.get_status_component()
	_enemy_2_status_component = _enemy_2.get_status_component()

	# Ready the entity stats
	# This is necessary only for the tests
	_player_stat_component.stats.ready_entity_stats()
	_enemy_stat_component.stats.ready_entity_stats()
	_enemy_2_stat_component.stats.ready_entity_stats()
	
	# Disable data saving so nothing is saved between tests
	_player._should_save_persistent_data = false
	_player_energy_component.ignore_cost = true
	CardManager.disable_card_animations = true
	PhaseManager.start_combat()

## Clear between tests
func after_each() -> void:
	DebugVar.DEBUG_USE_TEST_ENEMY_GROUP = false
	_player.queue_free()
	_enemy.queue_free()
	_enemy_2.queue_free()
	_battler.queue_free()
	_card_container.queue_free()
	# Check that everything has been set free properly [br]
	# This is mainly useful for the CI as some tests can fail silently and the only indication is that resources are not freed
	assert_no_new_orphans("Orphans still exist, please free up test resources.")
