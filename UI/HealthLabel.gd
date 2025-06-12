extends Label
## Simple setter that pulls from the health component.


@export var health_component: HealthComponent = null


func _ready() -> void:
	# default to showing player health
	if health_component == null:
		health_component = PlayerManager.player.get_health_component()
	health_component.on_health_changed.connect(_set_health)
	_set_health(health_component.current_health)


func _set_health(_new_health: float) -> void:
	text = str(health_component.current_health) + " / " + str(health_component.max_health)
