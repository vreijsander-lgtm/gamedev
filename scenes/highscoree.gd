extends Button
func _ready():
	if GameData.HighScore > 1000:
		GameData.HighScore = 1000
	set_text("Press to play again!\n\nHighscore: %d / 1000" %GameData.HighScore)
func _pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map.tscn")
