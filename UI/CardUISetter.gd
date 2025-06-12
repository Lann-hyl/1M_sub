extends Control
class_name CardUISetter
## Handles setting up UI on a card by pulling from CardBase card_data.
##
## The idea with using a UI setter like this is we don't have any references to UI stuff
## in the actual Card class, so we can keep that class as minimal as possible.

@export var key_art: TextureRect
@export var attack_ui: Control
@export var skill_ui: Control
@export var power_ui: Control

func _ready() -> void:
	var parent_card: CardWorld = get_parent() as CardWorld
	
	assert(parent_card != null, "Couldn't find parent card. Make sure this is attached to a card.")
	
	# wait for data to initialize if needed
	if parent_card.card_data != null:
		_on_card_initialized(parent_card.card_data)
	else:
		parent_card.on_card_data_initialized.connect(_on_card_initialized)


func _on_card_initialized(in_card_data: CardBase) -> void:
	var card_ui: Control
	if in_card_data.card_type == GlobalEnums.CardType.ATTACK:
		card_ui = attack_ui
	elif in_card_data.card_type == GlobalEnums.CardType.SKILL:
		card_ui = skill_ui
	else:
		card_ui = power_ui
	
	card_ui.visible = true
	var title_label: Label = card_ui.get_node("Title")
	title_label.text = in_card_data.card_title
	
	var description_label: Label = card_ui.get_node("Description")
	description_label.text = in_card_data.card_description
	
	var energy_label: Label = card_ui.get_node("Energy")
	energy_label.text = "E: " + str(in_card_data.energy_info.energy_cost)
	
	var author_label: Label = card_ui.get_node("Artist")
	author_label.text = "Art by: " + str(in_card_data.card_artist_name)
	
	if in_card_data.card_key_art:
		key_art.texture = in_card_data.card_key_art
	else:
		push_warning("No key art set in the card data. Using default")
