extends Area2D

var speed := 500.0
var max_range := 500.0
var distance_travelled := 0.0

@export var damage := 1

var enemy_bullet := false


func _ready() -> void:
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, enemy_bullet)

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta):
	var forward_direction = Vector2(0, -1).rotated(rotation)

	var movement = forward_direction * speed * delta
	position += movement

	distance_travelled += movement.length()

	if distance_travelled >= max_range:
		queue_free()


func _on_body_entered(body):
	if enemy_bullet and body.is_in_group("player"):
		body.take_damage(damage)
		
	queue_free()
func _on_area_entered(area):
	if enemy_bullet:
		return

	if area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()
