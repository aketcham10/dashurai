extends Node2D
var socks = 0: set = set_socks

func set_socks(value):
	socks = value
	$CanvasLayer/HUD.update_socks(value)
	$itemPickedUpSound.play()
	if (socks == 4):
		get_tree().change_scene_to_file("res://cutscenes/outro.tscn")

func _on_sock_picked_up() -> void:
	set_socks(socks + 1)

func _on_player_life_changed(value) -> void:
	$CanvasLayer/HUD.update_life(value)


func _on_sock_2_picked_up() -> void:
	set_socks(socks + 1)


func _on_sock_3_picked_up() -> void:
	set_socks(socks + 1)
