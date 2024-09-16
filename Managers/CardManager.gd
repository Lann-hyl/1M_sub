extends Node
## Global AutoLoaded class that allows you to get the card container from anywhere.


signal on_card_container_initialized
signal on_card_action_finished(card: CardWorld)
signal on_deck_initialized

var card_container: CardContainer = null
# We store the current deck in CardManager because we may want to access it outside of battle.
var current_deck: Array[CardBase] = []
var default_deck: CardSetBase = null

var disable_card_animations: bool = false


func _ready() -> void:
	default_deck = load("res://Cards/CardSets/DefaultDeck.tres")
	_initialize_deck()


# Call this from CardContainer to initialize. This allows you to get the current CardContainer from
# anywhere by calling CardManager.card_container
func set_card_container(in_card_container: CardContainer) -> void:
	card_container = in_card_container
	on_card_container_initialized.emit()
	
	if in_card_container != null:
		_initialize_deck()


func _initialize_deck() -> void:
	# Set our default deck.
	# NOTE: We assume that if the current_deck is empty, then this is the first time the game was loaded.
	if current_deck.is_empty():
		current_deck = default_deck.card_set.duplicate()
	on_deck_initialized.emit()


func is_discard_hand_signal_connected(callable: Callable) -> bool:
	return card_container != null and card_container.on_finished_discarding_hand.is_connected(callable)


func connect_discard_hand_signal(callable: Callable) -> void:
	card_container.on_finished_discarding_hand.connect(callable)

func save_data() -> void:
	var save_file: ConfigFile = SaveManager.save_file
	save_file.set_value("CardManager", "current_deck", current_deck)
	
	var error: Error = save_file.save("user://save/save_data.ini")
	if error:
		push_error("Error saving player data: ", error)

func load_data() -> void:
	var save_file: ConfigFile = SaveManager.load_save_file()
	if save_file == null:
		return
	
	if save_file.has_section_key("CardManager", "current_deck"):
		current_deck = save_file.get_value("CardManager", "current_deck")

func init_data() -> void:
	current_deck = default_deck.card_set.duplicate()

