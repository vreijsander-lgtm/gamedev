extends Button

func _pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map.tscn")
func _process(float) -> void:
	if Input.is_anything_pressed():
		get_tree().change_scene_to_file("res://scenes/map.tscn")
		
