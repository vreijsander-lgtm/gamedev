extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")

var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var ray_center = $RayCastCenter
@onready var ray_up = $RayCastUp
@onready var ray_down = $RayCastDown

@export var bullet_speed := 250.0
@export var bullet_range := 500.0
@export var shoot_cooldown := 0.5
@export var scan_speed := 30.0
@export var tracking_speed := 250.0
@export var max_health := 3
var current_health := 3
var current_ammo := 0
@export var max_ammo := 1
@export var reload_time_per_bullet := 1.0
var locked_on := false
var can_shoot := true

func _process(delta: float) -> void:
	if player == null:
		return

	if locked_on:
		var target_angle = global_position.direction_to(player.global_position).angle()

		rotation = rotate_toward(
			rotation,
			target_angle,
			deg_to_rad(tracking_speed) * delta
		)
		shoot()

	else:
		rotation += deg_to_rad(scan_speed) * delta

	check_vision()


func check_vision() -> void:
	for ray in [ray_center, ray_up, ray_down]:
		ray.force_raycast_update()

		if ray.is_colliding() and ray.get_collider() == player:
			locked_on = true
			return

	locked_on = false
func _ready() -> void:
	current_ammo = max_ammo
	current_health = max_health
	reload_ammo()
func reload_ammo() -> void:
	while true:
		await get_tree().create_timer(reload_time_per_bullet).timeout

		if current_ammo < max_ammo:
			current_ammo += 1
func shoot() -> void:
	if current_ammo <= 0:
		return

	if not can_shoot:
		return

	can_shoot = false

	var new_bullet = bullet_scene.instantiate()
	new_bullet.global_position = global_position

	var direction = global_position.direction_to(player.global_position)
	new_bullet.rotation = direction.angle() + PI / 2

	new_bullet.speed = bullet_speed
	new_bullet.max_range = bullet_range
	new_bullet.enemy_bullet = true

	get_tree().current_scene.add_child(new_bullet)

	current_ammo -= 1

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		queue_free()
