extends Resource
class_name CardBase
## Resource that holds data about a card and provides functions that all derived cards could
## use if they want.
##
## The intention with this is to provide functionality that is common to a lot of cards,
## like dealing damage, drawing cards, and restoring resources.[br]
## If you want functionality that's unique to a certain card, then create a new child of this
## and override one of the functions below.[br]
## This resource also has data that is used for displaying the card in the world, like
## description, title, and key art.[br]
## This includes functionality for applying damage to both the target and caster. Casters may
## wish to take damage in some contexts.[br]
## For example, consider the card: "Deal 10 damage to all enemies, but take 3 damage"

## Define the type of entity this card can be played on [br]
## Possible values: see [enum GlobalEnums.ApplicationType]
@export var application_type: GlobalEnums.ApplicationType = GlobalEnums.ApplicationType.ENEMY_ONLY

## The name of the card
@export var card_title: String = "NULL"

## The art used on the card (ie the image at the top, not the layout of the card)
@export var card_key_art: Texture2D = null

## Type of Card: Attack, Skill, or Power
@export var card_type: GlobalEnums.CardType = GlobalEnums.CardType.ATTACK

## The description of the card
@export var card_description: String = "NULL"

## Name of the artist that made the card art
@export var card_artist_name: String = "NULL"

## A list of the effects that the card will apply when played [br]
## Effect data is not purely the effect, it also contains information about targets among other things, see [EffectData]
@export var card_effects_data: Array[EffectData] = []

## How much energy is needed to play this card
@export var energy_info: EnergyData = EnergyData.new()

## Used to check the order in which effects and related animations are played
var _card_effects_queue: Array[EffectData] = []

## Used to check which targets have been hit by an effect [br]
## TODO this needs better phrasing
var _targets_triggered_hits: Array[Entity] = []


# ? is this actually needed anymore
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_effects_data = []

## Check if the caster can play the card on the target. This is different from checking if the player has enough energy. [br]
## Instead it checks if the application type of the card is compatible with the target (cannot play a card with an effect on enemies on yourself for example)
func can_play_card(caster: Entity, target: Entity) -> bool:
	return caster.get_party_component().can_play_on_entity(application_type, target)


## To be linked with a signal to activate this function. [br]
## Applies all the effects of the cards to the listed targets.
func on_card_play(caster: Entity, base_target: Entity) -> void:
	if caster is Player:
		PlayerManager.player.get_energy_component().use_energy(self)	
	
	if _card_effects_queue.size() > 0:
		push_error("Tried to play more card animations while some are already playing!")
		return
	
	_card_effects_queue = card_effects_data.duplicate()
	_handle_effects_queue(caster, base_target)


## Applies effects of the card sequentially, to ensure proper animation display
func _handle_effects_queue(caster: Entity, base_target: Entity) -> void:
	var card_effect: EffectData = _card_effects_queue[0]
	var animation_data: CastAnimationData = card_effect.animation_data
	var list_targets: Array[Entity] = card_effect.targeting_function.generate_target_list(base_target)
	var created_cast_animations: Array[CastAnimation] = []
	
	var can_use_animation: bool = animation_data != null and animation_data.can_use_animation()
	
	if can_use_animation:
		created_cast_animations = animation_data.cast_position.initialize_animation(animation_data.cast_animation_scene, caster, list_targets)
		
		# Wait for animation to trigger hits
		for cast_animation in created_cast_animations:
			cast_animation.on_animation_hit_triggered.connect(animation_hit.bind(card_effect, caster))
			cast_animation.play_animation()
	else:
		push_warning("No animation set in effect data for card " + resource_path + ". Skipping animation.")
		
		# Apply effects to all targets instantly if there is no animation
		for current_target in list_targets:
			card_effect.apply_effect_data(caster, current_target)
	
	# Wait for last animation to complete
	if not created_cast_animations.is_empty():
		await created_cast_animations[created_cast_animations.size() - 1].on_animation_cast_complete
		
		if list_targets != _targets_triggered_hits:
			push_error("Did not trigger a hit on all targets for effect " + card_effect.resource_path)
	
	_card_effects_queue.remove_at(0)
	_targets_triggered_hits.clear()
	
	# Handle next effect in the queue or finish casting
	if _card_effects_queue.size() > 0:
		_handle_effects_queue(caster, base_target)
	else:
		CardManager.on_card_action_finished.emit(self)


## Check whether or not a target has already been hit by an effect or not [br]
## @experimental
## This might change later for effects that can target the same entity multiple times
func animation_hit(hit_target: Entity, card_effect: EffectData, caster: Entity) -> void:
	if _targets_triggered_hits.has(hit_target):
		push_error("Hit was triggered on " + hit_target.name + " more than once! Skipping effects")
		return
	
	_targets_triggered_hits.append(hit_target)
	card_effect.apply_effect_data(caster, hit_target)
