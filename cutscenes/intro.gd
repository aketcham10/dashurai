extends Node2D

func _input(event: InputEvent) -> void:
	if event.is_action('jump'):
		get_tree().change_scene_to_file("res://levels/level_01.tscn")
