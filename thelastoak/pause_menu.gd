extends Control

func resume():
	get_tree().paused = false
	visible = false


func quit_to_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_resume_button_pressed() -> void:
	resume()


func _on_quit_button_pressed() -> void:
	quit_to_menu()
