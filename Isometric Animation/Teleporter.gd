extends Area



func _on_Teleporter_body_entered(body : Node):
	if body is Spatial:
		body.global_transform.origin = Vector3(0, 2.5, 0)


func _on_Teleporter_body_exited(body):
	pass # Replace with function body.
