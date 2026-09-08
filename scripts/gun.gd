extends Node2D	
@onready var other_node = get_node("../../Aim/Sprite2D")
func _process(delta: float) -> void:
	var target_pos = other_node.global_position
	look_at(target_pos)
