extends Control




func _on_back_pressed() -> void:
	SceneManager.goto_scene("res://#Scenes/MainMenu.tscn")


func _on_license_pressed() -> void:
	SceneManager.goto_scene("res://#Scenes/License.tscn")
