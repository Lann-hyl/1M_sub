extends Node
class_name GlobalEnums
## Global enums list

## For phases that are common between multiple events
enum GlobalPhase {
	NONE, ## Hello Youston, we are nowhere
	GAME_STARTING, ## The game is starting
	SCENE_STARTED, ## A new scene started
	SCENE_END, ## The current scene ended
}

## For phases that are combat specific
enum CombatPhase {
	REMOVE_BLOCK_ALLY, ## Remove the block of all allied entity
	PLAYER_TURN_START, ## Everything that happens to the player at the start of their turn except the block, like taking poison damage
	PLAYER_ATTACKING, ## The player is attacking
	PLAYER_FINISHING, ## The player finished its turn (card discard and other stuff starts here)
	REMOVE_BLOCK_ENEMY, ## Remove the block of all the enemies
	ENEMY_TURN_START, ## ## Everything that happens to enemies at the start of their turn except the block, like taking poison damage
	ENEMY_ATTACKING, ## Enemy turn
}

## In which team is an entity
enum Team
{
	ENEMY, ## This refers to the enemies (of the player)
	FRIENDLY, ## The allies of the player. Even though enemies are friendly between themselves, for the point of view of an enemy, another enemy is still an enemy
}

## Who can be affected by an action
enum ApplicationType
{
	FRIENDLY_ONLY, 
	ENEMY_ONLY,
	ALL,
}

## How the card can be cast
enum CardCastType
{
	TARGET, ## You need to select a target to play this card
	INSTA_CAST, ## You can just play the card and it will know the targets. For example, "deal 3 damage to all enemies" is insta cast
}

## Gives the position of the card on the screen
enum CardMovementState
{
	NONE,
	MOVING_TO_HAND, ## When coming from a deck
	IN_HAND, ## in the player hand, no particular state
	DISCARDING, ## Going from the play area to the discard pile
	HOVERED, ## The mouse of the player is on the card
	QUEUED, ## The card is queued to be played (this happens between the moment the player clicks on the card and the moment he selects a target if needed)
	PLAYING, ## The effects of the card are being played
}


## The level of light on the map
enum LightLevel
{
	UNLIT, ## No light at all
	DIMLY_LIT, ## No torch in range and the player is next to the room
	LIT, ## One torch in range of the room
	BRIGHTLY_LIT ## At least two torches in range of the room
}

## The two types of stats that an entity can have [br]
## The general way to calculate a value modified by stats is base + offense of caster - defense of target
enum EntityStatDictType {
	OFFENSE, ## used to calculate modifiers to a value by the caster
	DEFENSE ## Used the calculate modifiers to a value by the target
}


## The modifiers that can be applied to a value [br]
## This is equivalent to a tag [br]
## Each StatDictType (offense and defense) has all those possible modifiers [br]
## A value of 1 on the DAMAGE of OFFENSE means you deal one more damage [br]
## A value of 1 on the DAMAGE of DEFENSE means you take one less damage [br]
enum PossibleModifierNames {
	DAMAGE,
	STRESS,
	HEAL,
	SOOTH,
	POISON,
	DRAW,
	CARD_REWARD_NUMBER
}
# ! don't forget to update _ENTITY_STAT_DICT_SELECTOR in EntityStats.gd, the test_possible_modifier_size(especifically expected_size)
# in test_stats.gd if you modify this 

## All the possible types of events [br]
## @experimental
##! [method choose_event_from_type] and [var Global_var.EVENTS_PROBABILITIES] should be updated if you add a new event  
enum EventType {
	Random, # ! Random should always be the first element (see EventRandom)
	Heal,
	Mob,
	Shop,
	Dialogue,
}


enum SaplingType {
	Sleepy,
	Cool,
	Emo,
	Gamer,
	Maid,
	Milf,
	Nerd,
	Old,
	Snow,
	None,
}

## Helper function that returns the Event resource depending on the given EventType
static func choose_event_from_type(event_type: EventType) -> EventBase:
	match event_type:
		GlobalEnums.EventType.Random:
			return EventRandom.new()
		GlobalEnums.EventType.Heal:
			return EventHeal.new()
		GlobalEnums.EventType.Mob:
			return EventMob.new()
		GlobalEnums.EventType.Shop:
			return EventShop.new()
		GlobalEnums.EventType.Dialogue:
			return EventDialogue.new()
	# A case for an EventType has not been defined, so we arbitrarily return Random
	return EventRandom.new() 


## All the available enemies
enum PossibleEnemies {
	billy,
	cat_5_hurricane,
	cat_eyes,
	cubicle_villager,
	definitely_a_ku100,
	edgar_allen_poe,
	emu_ku100,
	family_friendly_pangolin,
	faun_club,
	four_dio,
	golden_cauldron,
	green_beans,
	he_moves_in_a_pentagram,
	ku10000,
	matter_baby,
	mushroomling,
	overflowing_blender_of_mac_n_cheese,
	placid_puddle,
	sapoling,
	seedlings,
	slime_in_jar,
	slime_mold,
	slimeling,
	snail,
	suited_bald_man,
	suspiciously_cheap_slime,
	swarm_of_insects,
	the_slide,
	the_snake,
	undefended_soccer_net,
	wendigo,
	spiral_of_ants,

	# Mini-boss
	attack_elephant,
	clarence_the_worm,
	fauna_inventory,
	motorized_bears,
	not_pickle,
	one_guy,
	orange_on_a_table,
	untuned_kalimba,
	# Boss
	asmr_rically_accurate_omni_angel,
	bethany,
	nemu,
	o_beehive,
	the_berts,
}

# Enums to each music track
enum MusicTrack {
	AREA_ONE,
	AREA_TWO,
	AREA_THREE,
	BOSS,
	HEAL,
	SHOP,
	MAIN_MENU,
	NO_TRACK
}

# Enums to each SFX
enum SoundEffect {
	UUUUU
}

enum CardType {
	ATTACK,
	SKILL,
	POWER
}
