extends Node

func _on_StartButton_button_down():
	get_tree().change_scene("res://Scenes/SmithingScene.tscn")


func _on_ExitButton_button_down():
	get_tree().quit()
