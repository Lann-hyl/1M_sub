extends Control
class_name CardContainer
## Lays out cards in the player's hand and spawns new cards.
##
## When a card is clicked, it is set as the queued_card.
## When a card is queued, you can't hover any other cards in your deck. Left click any card to
## remove the current card from the queue.
## TODO Right click cancels the queued card instead?


signal on_card_counts_updated
signal on_cards_finished_dealing
signal on_finished_discarding_hand

@export var card_scene: PackedScene
@export var total_hand_width: float = 100
@export var card_hovered_offset: float = 100
@export var card_queued_offset: float = 100
@export var starting_hand_size: int = 5
@export var max_hand_size: int = 10
@export var card_draw_time: float = 0.2
@export var card_discard_time: float = 0.1
@export var max_hand_width: float = 100
@export var min_card_separation: float = 100
@export var max_card_separation: float = 100
# Amount that other cards will scoot out of the way when you hover a card
@export var hover_offset_max: float = 50.0
@export var max_rotation: float = 30
# Max amount of visual offset for cards. Increasing this will make cards more "curved"
@export var max_hand_offset_y: float = 100
@export var draw_pile_ui: DrawPileUISetter = null
@export var discard_pile_ui: DiscardPileUISetter = null
# Height at where cards gets played
@export var play_at_height : float 


var cards_in_hand: Array[CardWorld] = []
var draw_pile: Array[CardBase] = []
var discard_pile: Array[CardBase] = []
var queued_card: CardWorld = null

var _active_card: CardWorld = null
var _focused_card: CardWorld = null
var _cards_queued_for_add: Array[CardBase] = []
var _draw_timer: SceneTreeTimer = null
var _cards_queued_for_discard: Array[CardWorld] = []
var _discard_timer: SceneTreeTimer = null

func _ready() -> void:
	PhaseManager.on_combat_phase_changed.connect(_on_phase_changed)
	CardManager.on_deck_initialized.connect(_init_default_draw_pile)
	CardManager.set_card_container(self)
	CardManager.on_card_action_finished.connect(finish_active_card_action.unbind(1))
	# ? all calls functions connected to on_card_action_finished don't even use the data of the card passed with the signal
	# ? does the signal even need to pass the card data since no function connected uses it ?


func _process(_delta: float) -> void:
	_update_card_positions()
	_handle_queued_card()


func set_queued_card(card: CardWorld) -> void:
	queued_card = card



# Remove card from focused and queued and remove it from the hand to prepare it to be played
func queued_for_active() -> void:
	_focused_card = null
	_remove_queued_card_from_hand()


func _remove_queued_card_from_hand() -> void:
	var _index_to_remove: int = cards_in_hand.find(queued_card)
	cards_in_hand.remove_at(_index_to_remove)


func is_card_queued() -> bool:
	return queued_card != null


func set_active_card(card: CardWorld) -> void:
	card.get_card_movement_component().set_movement_state(GlobalEnums.CardMovementState.PLAYING)
	_active_card = card


func finish_active_card_action() -> void:
	_discard_active_card()
	_active_card = null


func _discard_active_card() -> void:
	if (_active_card != null):
		# Add active_card to discard queued to trigger the discard animation
		_add_to_discard_queue(_active_card)
		
		# Add to the discard pile to update the counter
		discard_pile.append(_active_card.card_data)
		on_card_counts_updated.emit()


func are_cards_active() -> bool:
	return _active_card != null

func are_cards_dealing() -> bool:
	return _cards_queued_for_add.size() > 0


func deal_to_starting_hand_size() -> void:
	# deal to our starting hand size, ignoring amount of cards we already have
	var amount_to_draw: int = maxi(0, starting_hand_size - cards_in_hand.size())
	draw_cards(amount_to_draw)


func draw_cards(amount: int) -> void:
	for card_index: int in amount:
		# limit amount of cards to a maximum
		if get_total_queued_hand_size() < max_hand_size:
			_draw_card()


func discard_all_cards() -> void:
	# Discard cards until our hand is empty. We do it with a while-loop instead of a for-loop
	# because we don't want cards_in_hand to change size during the iteration
	while cards_in_hand.size() > 0:
		_discard_last_card()


func discard_random_card(amount: int) -> void:
	# Discard - clamping desired amount to the size of our current hand
	var amount_to_discard: int = mini(cards_in_hand.size(), amount)
	for discarding_index: int in amount_to_discard:
		var random_index: int = Helpers.get_random_array_index(cards_in_hand)
		discard_card(cards_in_hand[random_index])


func discard_card(card: CardWorld) -> void:
	var card_index: int = cards_in_hand.find(card)
	_discard_card_at_index(card_index)


func get_total_queued_hand_size() -> int:
	return _cards_queued_for_add.size() + cards_in_hand.size()


func get_draw_pile_size() -> int:
	return draw_pile.size()


func get_discard_pile_size() -> int:
	return discard_pile.size()


func _init_default_draw_pile() -> void:
	draw_pile = CardManager.current_deck.duplicate()
	draw_pile.shuffle()


# This is where cards are removed from the draw pile.
func _draw_card() -> void:
	# if draw pile is empty, shuffle discard pile into draw pile. Clear discard pile.
	if draw_pile.size() <= 0:
		# every card is in our hand. Exit because there's nothing to draw
		if discard_pile.size() <= 0:
			return
		discard_pile.shuffle()
		draw_pile = discard_pile.duplicate()
		discard_pile.clear()
	
	# top card on the draw pile
	var drawn_card: CardBase = draw_pile[0]
	draw_pile.remove_at(0)
	
	# add to queue for creation at a later time
	_add_to_card_draw_queue(drawn_card)
	
	on_card_counts_updated.emit()


# This is where a card is removed from the hand and added to the discard pile.
func _discard_card_at_index(card_index: int) -> void:
	var card: CardWorld = cards_in_hand[card_index]
	
	# add to discard pile
	discard_pile.append(card.card_data)
	# remove from hand and add to discard queue
	cards_in_hand.remove_at(card_index)
	_add_to_discard_queue(card)
	
	on_card_counts_updated.emit()


func _discard_last_card() -> void:
	if cards_in_hand.size() > 0:
		_discard_card_at_index(cards_in_hand.size() - 1)


func _add_to_card_draw_queue(card: CardBase) -> void:
	_cards_queued_for_add.append(card)
	_handle_card_draw_queue()


# Final place where a card is created and added to the world.
# NOTE: at this point, cards have already been removed from the draw pile.
# Cards are removed from the draw pile in _draw_card.
# _create_card_in_world spawns the cards from the queue and adds them to your hand.
func _handle_card_draw_queue() -> void:
	if _draw_timer != null:
		return
	
	var card_data: CardBase = _cards_queued_for_add[0]
	_cards_queued_for_add.remove_at(0)
	
	_create_card_in_world(card_data)
	
	# Wait for a timer to expire before adding another card
	_draw_timer = get_tree().create_timer(card_draw_time)
	await _draw_timer.timeout
	_draw_timer = null
	
	if _cards_queued_for_add.size() > 0:
		_handle_card_draw_queue()
	else:
		on_cards_finished_dealing.emit()


func _create_card_in_world(card_data: CardBase) -> void:
	var card: CardWorld = card_scene.instantiate()
	add_child(card)
	cards_in_hand.append(card)

	card.init_card(card_data)
	
	# set starting position of the card to the draw pile, so it visually shows it dealing from there
	if draw_pile_ui:
		card.global_position = draw_pile_ui.global_position

	# force an update of the card positions so all card positions are up to date with this new card
	_update_card_positions()
	
	var card_movement: CardMovementComponent = card.get_card_movement_component()
	card_movement.set_movement_state(GlobalEnums.CardMovementState.MOVING_TO_HAND)
	
	# Wait for card to finish moving, then bind input
	card_movement.on_movement_state_update.connect(_on_card_change_state.bind(card))


func _on_card_change_state(new_state: GlobalEnums.CardMovementState, card: CardWorld) -> void:
	# once we enter IN_HAND state, bind input
	if new_state == GlobalEnums.CardMovementState.IN_HAND:
		_bind_card_input(card)
		
		# unbind movement signal so it doesn't keep firing for every state
		card.get_card_movement_component().on_movement_state_update.disconnect(_on_card_change_state)


func _bind_card_input(card: CardWorld) -> void:
	# bind mouse events
	var card_click_handler: ClickHandler = card.get_click_handler()
	card_click_handler.on_click.connect(_on_card_clicked.bind(card))
	card_click_handler.on_mouse_hovering.connect(_on_card_hovering.bind(card))
	card_click_handler.on_unhover.connect(_on_card_unhovered.bind(card))


func _add_to_discard_queue(card: CardWorld) -> void:
	_cards_queued_for_discard.append(card)
	_handle_discard_queue()

const FIRST_CARD_TO_DISCARD_INDEX = 0;
# Looping queue that starts the discarding animation for cards.
# NOTE: a card is destroyed when the DISCARDING state is finished. See MoveState_Discarding
# NOTE: when you discard cards, they are removed from your hand and added to the discard pile
# immediately (see _discard_card_at_index).
# This function starts movement states on those cards that were queued and eventually
# destroys them.
func _handle_discard_queue() -> void:
	if _discard_timer != null:
		return
	
	var card: CardWorld = _cards_queued_for_discard[FIRST_CARD_TO_DISCARD_INDEX]
	_cards_queued_for_discard.remove_at(FIRST_CARD_TO_DISCARD_INDEX)
	
	# Set desired position to the discard pile UI and then set state
	var movement: CardMovementComponent = card.get_card_movement_component()
	if discard_pile_ui:
		movement.state_properties.desired_position = discard_pile_ui.global_position
	movement.set_movement_state(GlobalEnums.CardMovementState.DISCARDING)
	
	# Wait for timer to expire before discarding another card
	_discard_timer = get_tree().create_timer(card_discard_time)
	await _discard_timer.timeout
	_discard_timer = null
	
	if _cards_queued_for_discard.size() > 0:
		_handle_discard_queue()
	elif PhaseManager.current_combat_phase == GlobalEnums.CombatPhase.PLAYER_FINISHING:
		on_finished_discarding_hand.emit()


func _on_phase_changed(new_phase: GlobalEnums.CombatPhase, _old_phase: GlobalEnums.CombatPhase) -> void:
	if new_phase == GlobalEnums.CombatPhase.PLAYER_ATTACKING and !are_cards_dealing():
		deal_to_starting_hand_size()
	if new_phase == GlobalEnums.CombatPhase.PLAYER_FINISHING:
		if (cards_in_hand.size() == 0):
			on_finished_discarding_hand.emit()
		else:
			discard_all_cards()


func _on_card_clicked(card: CardWorld) -> void:
	if are_cards_active():
		return
	
	if is_card_queued():
		if(queued_card.card_cast_type == GlobalEnums.CardCastType.INSTA_CAST && is_queued_card_in_play_area()):
			play_card()
		else:
		
			var previously_queued_card: CardWorld = queued_card
		
			# If we click ANY card while we have one queued, unqueue the queued card
			set_queued_card(null)
		
			# If the card we clicked was the global queued card, we are still hovering it
			if card == previously_queued_card:
				_on_card_hovering(card)
			else:
				# If we clicked another card, then we already unhovered the queued card
				_on_card_unhovered(previously_queued_card)
				# Now call this function again for the card we clicked, which should queue it
				_on_card_clicked(card)
	else:
		# If we click a card with no card queued, queue it
		if PlayerManager.player.get_energy_component().is_playable(card):
			set_queued_card(card)

			card.get_card_movement_component().set_movement_state(GlobalEnums.CardMovementState.QUEUED)
			_focus_card(card)
		else:
			set_queued_card(null)

func play_card(target : Entity = null) -> void:
	queued_for_active()
	set_active_card(queued_card)
	set_queued_card(null)
	_active_card.card_data.on_card_play(PlayerManager.player, target)
	

func _on_card_hovering(card: CardWorld) -> void:
	if !is_card_queued() and !are_cards_active():
		card.get_card_movement_component().set_movement_state(GlobalEnums.CardMovementState.HOVERED)
		_focus_card(card)


func _on_card_unhovered(card: CardWorld) -> void:
	if !is_card_queued() and !are_cards_active():
		card.get_card_movement_component().set_movement_state(GlobalEnums.CardMovementState.IN_HAND)
		_unfocus_card(card)


func _focus_card(card: CardWorld) -> void:
	_focused_card = card
	
	# children at the top of the hierarchy will render in front
	move_child(card, get_child_count())


func _unfocus_card(card: CardWorld) -> void:
	_focused_card = null
	
	# move back to original place in the hierarchy
	var card_index: int = cards_in_hand.find(card)
	move_child(card, card_index)


func _update_card_positions() -> void:
	var amount_of_cards: int = cards_in_hand.size()
	
	if amount_of_cards <= 0:
		return
	
	# set hand width to the max of all our card separations
	var per_card_separation: float = max_card_separation
	var current_hand_width: float = 0
	if amount_of_cards > 1:
		current_hand_width = per_card_separation * (amount_of_cards - 1)
	
	# if our hand width is over the set maximum, reduce down the width between cards
	# only reduce down to the min_card_separation
	if current_hand_width > max_hand_width:
		var amount_hand_over_max: float = current_hand_width - max_hand_width
		var new_per_card_separation_delta: float = amount_hand_over_max / amount_of_cards
		
		per_card_separation -= new_per_card_separation_delta
		per_card_separation = maxf(per_card_separation, min_card_separation)
		
		current_hand_width = per_card_separation * (amount_of_cards - 1)
	
	# start setting positions for each card
	for card_index: int in amount_of_cards:
		var card: CardWorld = cards_in_hand[card_index]
		var movement_component: CardMovementComponent = card.get_card_movement_component()
		
		var card_x: float = per_card_separation * card_index
		var card_y: float = 0.0
		
		# center cards in the hand
		card_x -= current_hand_width / 2.0
		
		# if we are focusing a card, scoot other cards out of the way
		# we move closer cards further away, which results in a sort of "accordion" effect
		if _focused_card != null:
			var focused_card_index: int = cards_in_hand.find(_focused_card)
			if card_index != focused_card_index:
				var scaled_hover_offset: float = hover_offset_max
				var index_delta: float = card_index - focused_card_index
				scaled_hover_offset = scaled_hover_offset / index_delta
				card_x += scaled_hover_offset
		
		# scale card's x-value to a range of [-1, 1] from range of [0, viewport width]
		# this is so we can use the x-value more easily for our positioning equations below
		var viewport_width: float = get_viewport_rect().size.x
		var card_x_scaled: float = Helpers.convert_from_range(card.global_position.x, 0.0, viewport_width, -1.0, 1.0)
		
		# curve the cards in hand by finding the y value on a parabola
		# y = ax^2 - a where a = max_hand_offset_y and x = x position scaled to a range of -1 to 1
		card_y = (pow(card_x_scaled, 2.0) * max_hand_offset_y) - max_hand_offset_y
		
		# rotate cards on a cubic curve
		# y = ax^3 where a = max_rotation and x = x position scaled to a range of -1 to 1
		var rotation_amount: float = pow(card_x_scaled, 3) * max_rotation
		
		# set position and rotation
		movement_component.state_properties.desired_position = Vector2(card_x, card_y)
		movement_component.state_properties.desired_rotation = rotation_amount

func un_queue_card(card : CardWorld) -> void:
	set_queued_card(null)
	_unfocus_card(card)
	card.get_card_movement_component().set_movement_state(GlobalEnums.CardMovementState.IN_HAND)

func is_queued_card_in_play_area() -> bool:
	return get_global_mouse_position().y < play_at_height or are_cards_active()

func _handle_queued_card() -> void:
	if(queued_card == null):
		return
		
	#check if right button is pressed
	if(Input.is_action_just_pressed("cancel_queued_card_in_battle")):
		un_queue_card(queued_card)
	pass
