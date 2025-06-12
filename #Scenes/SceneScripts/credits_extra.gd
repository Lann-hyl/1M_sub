extends TextureRect

func _ready() -> void:
	self.modulate.a = 1
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 1)
	await get_tree().create_timer(10).timeout
	var out_tween: Tween = get_tree().create_tween()
	out_tween.tween_property(self, "modulate:a", 1, 2)
	await get_tree().create_timer(3).timeout
	SceneManager.goto_scene("res://#Scenes/MainMenu.tscn")
	

