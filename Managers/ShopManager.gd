extends Node
## Manager class for the shop

## price for card removal at the shop events
var card_removal_price : int = 50
var card_remocal_price_increase : int = 25

## the item pools for the various things provided in the shop[br]
@export var shop_card_pool : Array
@export var shop_relic_pool : Array
@export var shop_consumable_pool : Array

func increase_removal_price() -> void:
	card_removal_price += card_remocal_price_increase

## Removes given card, takes money, and increases shop prices. Should only be used by the shop removal[br]
## or potentionaly a specific event
func remove_card_from_player_deck_with_price(card : CardBase) -> void:
	if(!InventoryManager.gold_component.can_afford(ShopManager.card_removal_price)):
		return
	
	CardManager.current_deck.erase(card)
	InventoryManager.gold_component.lose_gold(card_removal_price)
	increase_removal_price()

## Should be used any time card should be removed from deck
func remove_card_from_player_deck_without_price(card : CardBase) -> void:
	CardManager.current_deck.erase(card)
