extends Label
## Gold counter display in the top right. Should handle updates when gold changes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_gold_text(InventoryManager.gold_component.get_gold_amount())
	InventoryManager.gold_component.gold_changed.connect(update_gold_text)

func update_gold_text(new_gold_amount : int) -> void:
	text = "Gold : " + str(new_gold_amount)
