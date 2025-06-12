extends Node

var save_file: ConfigFile
var save_file_path: String = "user://save/save_data.ini"

func _ready() -> void:
	save_file = ConfigFile.new()
	if !DirAccess.dir_exists_absolute("user://save/"):
		DirAccess.make_dir_absolute("user://save/")

func execute_save() -> void:
	XpManager.save_data()
	PlayerManager.save_player()
	MapManager.save_map_data()
	InventoryManager.save_inventory()
	CardManager.save_data()
	SceneManager.save_scene_data()
	EnemyManager.save_data()

func clear_data() -> void:
	DirAccess.remove_absolute("user://save/current_scene.tscn")
	DirAccess.remove_absolute(SaveManager.save_file_path)

func load_save_file() -> ConfigFile:
	if FileAccess.file_exists(SaveManager.save_file_path):
		var error: Error = save_file.load(SaveManager.save_file_path)
		
		if error:
			push_error("Error loading save_data ", error)
			return null
		
		return save_file
	else:
		return null

func has_saved_data() -> bool:
	var save_file_loc: ConfigFile = SaveManager.load_save_file()
	return save_file_loc != null
