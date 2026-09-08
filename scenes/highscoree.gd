extends Button
func _ready():
	set_text("Press to play again!\n\nHighscore: %d" %GameData.HighScore)
	await get_tree().create_timer(1).timeout
func _pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map.tscn")
func _process(float) -> void:
	if Input.is_anything_pressed():
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://scenes/map.tscn")
