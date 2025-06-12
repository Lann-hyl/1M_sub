extends Control
class_name ShopItem

## base class for all items sold in the shop
## The classes deriving from this are named shopitem[item which is sold]

@export var cost : int
@export var priceLabel : Label

func _ready() -> void:
	priceLabel.text = str(cost)

func on_shop_item_clicked() ->void:
	if(InventoryManager.gold_component.can_afford(cost)):
		queue_free()
		InventoryManager.gold_component.lose_gold(cost)
		_give_player_item()
	else:
		print("can't afford")

## this is an abstract class where each of the derived classes change to give the player their item
func _give_player_item() -> void:
	pass
