extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var health_container = get_node("../CanvasLayer/HBoxContainer")
@onready var ammo_bar = get_node("../CanvasLayer/ProgressBar")

@onready var other_node = get_node("../Aim/Sprite2D")
@export_range(0, 1000) var speed := 60.0

@export var max_health := 6
var current_health := 0
@onready var tilemap: TileMapLayer = $"../TileMapLayer"

var can_take_spike_damage := true
@export var spike_damage_cooldown := 1.0
var heart_full = preload("res://art/heart_full.png")
var heart_half = preload("res://art/heart_half.png")
var heart_empty = preload("res://art/heart_empty.png")
@onready var player_collision = $CollisionShape2D
@export var bullet_speed := 500.0
@export var bullet_range := 500.0
@export var shoot_cooldown := 0.5
@export var damage := 1
@export var max_ammo := 6
@export var reload_time_per_bullet := 1.0

var current_ammo := 0
var can_shoot := true

var bullet_scene = preload("res://scenes/bullet.tscn")


func _ready() -> void:
	current_ammo = max_ammo
	current_health = max_health
	ammo_bar.max_value = max_ammo
	ammo_bar.value = current_ammo

	update_health_display()
	update_ammo_bar()
	reload_ammo()


func _physics_process(_delta: float) -> void:
	get_player_input()
	move_and_slide()
	check_tile_damage()

func get_player_input() -> void:
	var vector := Input.get_vector("left", "right", "up", "down")
	velocity = vector * speed

	if vector.x < 0:
		animated_sprite.flip_h = false
	elif vector.x > 0:
		animated_sprite.flip_h = true

	if vector.x > 0:
		animated_sprite.play("right")
	elif vector.x < 0:
		animated_sprite.play("left")
	elif vector.y < 0:
		animated_sprite.play("up")
	elif vector.y > 0:
		animated_sprite.play("down")
	else:
		animated_sprite.play("default")

	if Input.is_action_pressed("click") and can_shoot:
		shoot()
	if Input.is_action_pressed("menu"):
		GameData.HighScore = 0
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://scenes/highscore_.tscn")
func shoot() -> void:
	if current_ammo <= 0:
		return
	
	can_shoot = false

	var new_bullet = bullet_scene.instantiate()
	new_bullet.damage = damage
	new_bullet.global_position = global_position

	var target_pos = other_node.global_position
	var direction = global_position.direction_to(target_pos)
	new_bullet.rotation = direction.angle() + PI / 2

	new_bullet.speed = bullet_speed
	new_bullet.max_range = bullet_range

	get_tree().current_scene.add_child(new_bullet)

	current_ammo -= 1
	ammo_bar.value = current_ammo

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
func reload_ammo() -> void:
	while true:
		await get_tree().create_timer(reload_time_per_bullet).timeout

		if current_ammo < max_ammo:
			current_ammo += 1
			ammo_bar.value = current_ammo
func update_health_display() -> void:
	for child in health_container.get_children():
		child.queue_free()

	var heart_count = int(ceil(max_health / 2.0))

	for i in range(heart_count):
		var heart = TextureRect.new()

		heart.custom_minimum_size = Vector2(24, 24)
		heart.size = Vector2(24, 24)

		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		var heart_health = current_health - (i * 2)

		if heart_health >= 2:
			heart.texture = heart_full
		elif heart_health == 1:
			heart.texture = heart_half
		else:
			heart.texture = heart_empty

		health_container.add_child(heart)
func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(current_health, 0)

	update_health_display()
	GameData.HighScore -= 400
	if current_health <= 0:
		get_tree().change_scene_to_file("res://scenes/highscore_.tscn")
func heal(amount: int) -> void:
	current_health += amount
	current_health = min(current_health, max_health)

	update_health_display()
func upgrade_health() -> void:
	max_health += 2
	current_health += 2

	update_health_display()
func check_tile_damage() -> void:
	var shape = player_collision.shape

	if shape == null:
		return

	var half_width := 8.0
	var half_height := 8.0

	if shape is RectangleShape2D:
		half_width = shape.size.x / 2.0
		half_height = shape.size.y / 2.0

	var collision_center = player_collision.global_position

	var points = [
		collision_center,
		collision_center + Vector2(-half_width, 0),
		collision_center + Vector2(half_width, 0),
		collision_center + Vector2(0, -half_height),
		collision_center + Vector2(0, half_height),
		collision_center + Vector2(-half_width, -half_height),
		collision_center + Vector2(half_width, -half_height),
		collision_center + Vector2(-half_width, half_height),
		collision_center + Vector2(half_width, half_height)
	]

	for point in points:
		var local_position = tilemap.to_local(point)
		var tile_position = tilemap.local_to_map(local_position)

		var tile_data = tilemap.get_cell_tile_data(tile_position)

		if tile_data == null:
			continue

		var damage = tile_data.get_custom_data("damage")

		if damage != null and damage > 0:
			if can_take_spike_damage:
				take_damage(int(damage))

				if current_health > 0:
					start_spike_cooldown()

			return
func start_spike_cooldown() -> void:
	can_take_spike_damage = false

	await get_tree().create_timer(spike_damage_cooldown).timeout

	can_take_spike_damage = true
func update_ammo_bar():
	ammo_bar.max_value = max_ammo
	ammo_bar.value = current_ammo
