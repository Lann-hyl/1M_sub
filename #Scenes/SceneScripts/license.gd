extends Control

@onready var license_label: Label = $"License label"

const MIT_LICENSE_TEXT: String = '\nMIT License

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'

func _ready() -> void:
	license_label.text = ''

func _on_godot_engine_pressed() -> void:
	license_label.text = '

	This game uses Godot Engine, available under the following license:

	Copyright (c) 2014-present Godot Engine contributors. Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
	'
	
	license_label.text += MIT_LICENSE_TEXT


func _on_dialogue_manager_pressed() -> void:
	license_label.text = "Dialogue System by Nathan Hoad: https://github.com/nathanhoad/godot_dialogue_manager\n"
	license_label.text += "Copyright (c) 2022-present Nathan Hoad and Dialogue Manager contributors.\n"
	license_label.text += MIT_LICENSE_TEXT


func _on_smooth_scroll_pressed() -> void:
	license_label.text = "Smooth Scroll by SpyrexDE: https://github.com/SpyrexDE/SmoothScroll\n"
	license_label.text += "Copyright (c) 2022 Fabian Keßler\n"
	license_label.text += MIT_LICENSE_TEXT


func _on_free_type_pressed() -> void:
	license_label.text = "Portions of this software are copyright © 2023 The FreeType Project (www.freetype.org). All rights reserved.
"


# Final version of the game should use a template without ENet
func _on_e_net_pressed() -> void:
	license_label.text = "Copyright (c) 2002-2024 Lee Salzman.\n"
	license_label.text += MIT_LICENSE_TEXT


func _on_mbed_tls_pressed() -> void:
	license_label.text = "Copyright The Mbed TLS Contributors\n\n"
	license_label.text += Engine.get_license_info()["Apache-2.0"]


func _on_go_back_pressed() -> void:
	SceneManager.goto_scene("res://#Scenes/MainMenu.tscn")
