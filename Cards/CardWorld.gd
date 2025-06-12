extends Control
class_name CardWorld
## Card object that exists in the world. Not to be confused with CardBase,
## which holds a card's data.


signal on_card_data_initialized(card_data: CardBase)

var card_data: CardBase = null
var card_cast_type : GlobalEnums.CardCastType = GlobalEnums.CardCastType.INSTA_CAST

func _ready() -> void:
	PhaseManager.on_combat_phase_changed.connect(_on_phase_changed)


func init_card(in_card_data: CardBase) -> void:
	card_data = in_card_data
	on_card_data_initialized.emit(card_data)
	
	for effectData : EffectData in card_data.card_effects_data:
		if(effectData.targeting_function.cast_type == GlobalEnums.CardCastType.TARGET):
			card_cast_type = GlobalEnums.CardCastType.TARGET
			break

## takes money and increases price of shop removal, should only be used when this is wanted
func remove_this_from_player_deck_with_price() -> void:
	if(!InventoryManager.gold_component.can_afford(ShopManager.card_removal_price)):
		return
	
	ShopManager.remove_card_from_player_deck_with_price(card_data)

## this should be used most of the time we want to take a card from the player
func remove_this_from_player_deck_without_price() -> void:
	ShopManager.remove_card_from_player_deck_without_price(card_data)

func _on_phase_changed(new_phase: GlobalEnums.CombatPhase, _old_phase: GlobalEnums.CombatPhase) -> void:
	# enable clicks on card only if player is in attack phase
	get_click_handler().set_interactable(new_phase == GlobalEnums.CombatPhase.PLAYER_ATTACKING)


func get_card_movement_component() -> CardMovementComponent:
	return Helpers.get_first_child_node_of_type(self, CardMovementComponent) as CardMovementComponent


func get_click_handler() -> ClickHandler:
	return Helpers.get_first_child_node_of_type(self, ClickHandler) as ClickHandler
