extends Node2D
func _process(_delta: float) -> void:
	var mouse = get_global_mouse_position()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	global_position = mouse
