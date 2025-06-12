extends TextureButton

var button_has_been_pressed: bool
@onready var black_overlay: TextureRect = $"../BlackOverlay"

func _ready() -> void:
	black_overlay.modulate.a = 0
	disabled = false
	visible = true

func _on_pressed() -> void:
	disabled = true
	var tween_to_black: Tween = get_tree().create_tween()
	# turn screen black
	tween_to_black.tween_property(black_overlay, "modulate:a", 1, 2)
	var player_health_comp: HealthComponent = PlayerManager.player.get_health_component()
	var max_health: int = player_health_comp.max_health
	var heal_amount: int = ceil(max_health * 0.25)

	# wait for screen to be black before healing
	await tween_to_black.finished
	visible = false
	player_health_comp.heal(heal_amount, null)
	# wait a bit
	await get_tree().create_timer(2).timeout

	var tween_to_clear: Tween = get_tree().create_tween()
	# remove black screen
	tween_to_clear.tween_property(black_overlay, "modulate:a", 0, 3)
	PlayerManager.player_room.room_event.on_event_ended()
	
