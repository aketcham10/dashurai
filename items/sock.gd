extends Area2D
signal picked_up


func _ready() -> void:
	monitoring = true
	# connect("body_entered", self, "_on_body_entered")
	# connect("area_entered", self, "_on_area_entered")
	# connect("body_shape_entered", self, "_on_body_shape_entered")
	print("Sock ready - collision_layer:", collision_layer, "collision_mask:", collision_mask)


func _on_body_entered(_body: Node) -> void:
	#print("Sock: body_entered ->", body)
	picked_up.emit()
	queue_free()
