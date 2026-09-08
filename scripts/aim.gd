extends CharacterBody2D

@export_range(0, 1000) var speed := 200.0

func _physics_process(_delta: float) -> void:
	get_player_input()
	move_and_slide()
func get_player_input() -> void:
	var vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = vector * speed
	#GameData.current_locationx = global_position.x
	#GameData.current_locationy = global_position.y
	#print(GameData.current_locationx)
	#print(GameData.current_locationy)
	#var curr_posy = position.y
	#var curr_posx = position.x
	#GameData.current_locationy = curr_posy
	#GameData.current_locationx = curr_posx
