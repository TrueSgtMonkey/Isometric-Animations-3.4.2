extends Node

func _input(event):
	if event.is_action_pressed("EXIT_GAME"):
		get_tree().quit()
