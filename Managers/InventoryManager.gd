extends Node

## The Inventory Manager is split into part for each item that needs to be held track of [br]
## If a new item is ever needed we can just make a new InventoryComponent and add it to this list [br]
## To get any of the items we can use InventoryManager.example_component.get_example_item()

var gold_component : InventoryGoldComponent = InventoryGoldComponent.new()
var torch_component : InventoryTorchComponent = InventoryTorchComponent.new()
var consumable_component : InventoryConsumablesComponent = InventoryConsumablesComponent.new()
var relic_component : InventoryRelicComponent = InventoryRelicComponent.new()

## This is for the UI [br]
## The current UI is a placeholder and wil be changed in the future

var inventory_HUD : PackedScene = preload("res://InventoryComponents/InventoryHUD/inventory_hud.tscn")
var instanced_inventory_HUD : Node

func instance_inventory_HUD() -> void:
	instanced_inventory_HUD = inventory_HUD.instantiate()
	add_child(instanced_inventory_HUD)

func close_inventory_HUD() -> void:
	if(instanced_inventory_HUD == null):
		return
	
	instanced_inventory_HUD.queue_free()

func toggle_inventory_HUD() -> void:
	if(instanced_inventory_HUD == null):
		instance_inventory_HUD()
	else:
		close_inventory_HUD()

func has_torches() -> bool:
	return torch_component.has_torches()

func subtract_torch() -> void:
	torch_component.lose_torches(1)

## Simply just makes new versions of every component class to reset all the items [br]
## The inventory_hud is closed before hand in case something breaks there

func init_data() -> void:
	close_inventory_HUD()
	gold_component = InventoryGoldComponent.new()
	torch_component = InventoryTorchComponent.new()
	consumable_component = InventoryConsumablesComponent.new()
	relic_component = InventoryRelicComponent.new()

func save_inventory() -> void:
	var save_file: ConfigFile = SaveManager.save_file
	save_file.set_value("InventoryManager", "gold_component", gold_component)
	save_file.set_value("InventoryManager", "torch_component", torch_component)
	save_file.set_value("InventoryManager", "consumable_component", consumable_component)
	save_file.set_value("InventoryManager", "relic_component", relic_component)
	
	var error: Error = save_file.save("user://save/save_data.ini")
	if error:
		push_error("Error saving inventory data: ", error)

func load_inventory() -> void:
	var save_file: ConfigFile = SaveManager.load_save_file()
	if save_file == null:
		return
	
	if save_file.has_section_key("InventoryManager", "gold_component"):
		gold_component = save_file.get_value("InventoryManager", "gold_component")
	
	if save_file.has_section_key("InventoryManager", "torch_component"):
		torch_component = save_file.get_value("InventoryManager", "torch_component")
	
	if save_file.has_section_key("InventoryManager", "consumable_component"):
		consumable_component = save_file.get_value("InventoryManager", "consumable_component")
	
	if save_file.has_section_key("InventoryManager", "relic_component"):
		relic_component = save_file.get_value("InventoryManager", "relic_component")
