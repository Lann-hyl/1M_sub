extends Control

var card_scene: PackedScene = preload("res://Cards/Card.tscn")

var cards_to_display: Array[CardBase] = []
var card_worlds: Array[CardWorld] = []
var cardworld: CardWorld = null
var cardui: Control = null
var key_art: Control = null

@onready var button : Button = $Button

const KEY_ART_SCALE: Vector2 = Vector2(1, 1)
const CARD_SCALE: Vector2 = Vector2(1, 1)
const CARDUI_INDEX: int = 2
const CARDUI_POS: Vector2 = Vector2(150,275)
const KEYART_UI_OFFSET: Vector2 = Vector2(50, 130)
const SIZE_OFFSET: Vector2 = Vector2(10,10)

#deletes the root node CardScrollUI with the on screen button
func _on_button_pressed() -> void:
	queue_free()
	

#deletes the root node CardScrollUI with the escape key
func _input(_inputevent: InputEvent) -> void:
	if (_inputevent.is_action_pressed("cancel_action")):
		queue_free()



func populate(parent_name: String) -> void:
	
	var cardRemoval : bool = false
	
	match parent_name:
		"DiscardPile":
			cards_to_display = CardManager.card_container.discard_pile
			$Label.text = "Showing the discard pile"
		"DrawPile":
			cards_to_display = CardManager.card_container.draw_pile
			$Label.text = "Showing the draw pile"
		"DeckPile":
			cards_to_display = CardManager.current_deck
			$Label.text = "Showing the deck pile"
		"CardRemoval":
			cards_to_display = CardManager.current_deck
			$Label.text = "Pick a card to remove"
			cardRemoval = true
	cards_to_display.sort_custom(card_sort_by_title)

	for card: CardBase in cards_to_display:

		cardworld = card_scene.instantiate()
		cardui = cardworld.get_node("CardUI")
		key_art = cardworld.get_node("KeyArt")
	
		cardui = cardworld.get_child(CARDUI_INDEX)

		cardworld.custom_minimum_size = (cardui.size * CARD_SCALE) + SIZE_OFFSET
		cardui.scale = CARD_SCALE
		cardui.anchors_preset = CORNER_TOP_LEFT
		cardui.position = CARDUI_POS
		
		if(cardRemoval):
			cardworld.get_click_handler().on_click.connect(close_card_scroll)
			cardworld.get_click_handler().on_click.connect(cardworld.remove_this_from_player_deck_with_price)


		$ScrollContainer/GridContainer.add_child(cardworld)
		
		cardworld.init_card(card)

func close_card_scroll() -> void:
	queue_free()

func card_sort_by_title(card_A: CardBase, card_B: CardBase) -> bool:
	if card_A.card_title.to_lower() < card_B.card_title.to_lower():
		return true
	return false

