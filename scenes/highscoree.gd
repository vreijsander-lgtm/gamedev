extends Button
func _ready():
	if GameData.HighScore > 1000:
		GameData.HighScore = 1000
	set_text("Press to play again!\n\nHighscore: %d / 1000" %GameData.HighScore)
	await get_tree().create_timer(1).timeout
func _pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map.tscn")
func _process(float) -> void:
	if Input.is_anything_pressed():
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://scenes/map.tscn")
