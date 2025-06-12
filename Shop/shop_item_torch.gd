extends ShopItem

@export var clickHandler : ClickHandler
var torchTexture : PackedScene = preload("res://Shop/tourchDisplay.tscn")
@export var amount : int
@export var startPosTransform : Node2D
var heldTorches : Array[TextureRect]

func _ready() -> void:
	clickHandler.on_click.connect(on_shop_item_clicked)
	
	var startPos : Vector2 = startPosTransform.position
	
	## Instansiates the amount of torches held in this item. [br]
	## Each torch is moved a set distance away from the last
	for i in amount:
		var instance : TextureRect = torchTexture.instantiate()
		heldTorches.append(instance) 
		instance.position = startPos
		
		var torch_distance : float = 5
		
		startPos += Vector2.RIGHT * torch_distance
		add_child(instance)
	
	super()

func on_shop_item_clicked() ->void:
	if(InventoryManager.gold_component.can_afford(cost)):
		InventoryManager.gold_component.lose_gold(cost)
		_give_player_item()
	else:
		print("can't afford")


func _give_player_item() -> void:
	heldTorches.pop_back().queue_free()
	InventoryManager.torch_component.add_torches(1)
