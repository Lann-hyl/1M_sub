extends Control


func _on_back_to_main_menu_pressed() -> void:
	AudioManager.stop_music()
	SceneManager.goto_scene("res://#Scenes/MainMenu.tscn")
