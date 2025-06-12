extends CardMovementState
class_name MoveState_Queued
## Queued state. Moves to desired position with a y-offset


const MOVE_SPEED: float = 10.0
const EASE_TIME: float = 0.5
const EASE_TYPE: Tween.EaseType = Tween.EASE_OUT
const TRANS_TYPE: Tween.TransitionType = Tween.TRANS_CUBIC
const QUEUE_OFFSET: float = -150
const SCALE_AMOUNT: Vector2 = Vector2(1.3, 1.3)
const OFFSET_FROM_MOUSE : Vector2 = Vector2(0, 100)
#Position of card if it's target type
const TARGET_CARD_POS : Vector2 = Vector2(-500, -500)

# @Override
func on_state_enter() -> void:
	# Scale to SCALE_AMOUNT
	_state.card.create_tween()\
	.tween_property(_state.card, EasingConstants.SCALE_PROPERTY, SCALE_AMOUNT, EASE_TIME)\
	.set_ease(EASE_TYPE)\
	.set_trans(TRANS_TYPE)


# @Override
func on_state_process(delta: float) -> void:
	# Ease position with an offset
	var offset_desired_position: Vector2 = _state.card.get_global_mouse_position()
	offset_desired_position.y += QUEUE_OFFSET
	offset_desired_position -= _state.card.get_parent().position
	offset_desired_position += OFFSET_FROM_MOUSE
	
	var is_in_play_area : bool = CardManager.card_container.is_queued_card_in_play_area()
	var is_not_insta_cast : bool = _state.card.card_cast_type != GlobalEnums.CardCastType.INSTA_CAST
	
	if(is_in_play_area && is_not_insta_cast):
		_state.card.position = _state.card.position.lerp(TARGET_CARD_POS, delta * MOVE_SPEED)
	else :
		_state.card.position = _state.card.position.lerp(offset_desired_position, delta * MOVE_SPEED)
	
	# Ease rotation
	_state.card.rotation_degrees = lerpf(_state.card.rotation_degrees, 0.0, delta * MOVE_SPEED)
