extends CollisionShape2D
func _on_body_entered(_body):
	if _body.is_in_group("player"):
		get_tree().change_scene_to_file("res://scenes/boss_room.tscn")
