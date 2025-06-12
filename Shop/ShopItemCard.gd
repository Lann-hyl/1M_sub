extends ShopItem

@export var cardWorld : CardWorld
var card : CardBase

func _ready() -> void:
	card = ShopManager.shop_card_pool[RandomGenerator.get_random_int(0, ShopManager.shop_card_pool.size() - 1)]
	
	cardWorld.init_card(card)
	cardWorld.get_click_handler().on_click.connect(on_shop_item_clicked)
	super()


func _give_player_item() -> void:
	CardManager.current_deck.append(card)
