extends ShopItem

var consumable : Consumable
@export var consumableImage : TextureButton
@export var clickHandler : ClickHandler


func _ready() -> void:
	consumable = ShopManager.shop_consumable_pool[RandomGenerator.get_random_int(0, ShopManager.shop_consumable_pool.size() - 1)]
	
	
	consumableImage.texture_normal = load(consumable.image_path)
	clickHandler.on_click.connect(on_shop_item_clicked)
	super()


func _give_player_item() -> void:
	InventoryManager.consumable_component.add_consumable(consumable)
