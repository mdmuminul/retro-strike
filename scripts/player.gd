extends CharacterBody2D

@export var speed: float = 300.0
@export var shoot_cooldown: float = 0.25
@export var max_ammo: int = 25
@export var reload_time: float = 2.0

@onready var bullet_spawn: Marker2D = $BulletSpawn

var screen_size: Vector2
var current_ammo: int
var is_reloading: bool = false
var cooldown_timer: float = 0.0
var can_control: bool = true

var ammo_label: Label

var bullet_scene = preload("res://scenes/bullet/bullet.tscn")


func _ready():
	add_to_group("player")

	screen_size = get_viewport_rect().size
	current_ammo = max_ammo

	ammo_label = get_tree().current_scene.get_node_or_null(
		"UI/AmmoContainer/AmmoLabel"
	)

	update_ammo_display()


func _physics_process(delta):
	if not can_control:
		velocity = Vector2.ZERO
		return

	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	var input_direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	# Mouse movement
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_position := get_global_mouse_position()
		var mouse_direction := mouse_position - global_position

		if mouse_direction.length() > 10.0:
			input_direction = mouse_direction.normalized()

	velocity = input_direction.normalized() * speed

	move_and_slide()

	# Keep player inside screen
	var margin: float = 40.0

	position.x = clamp(
		position.x,
		margin,
		screen_size.x - margin
	)

	position.y = clamp(
		position.y,
		margin,
		screen_size.y - margin
	)

	# Shoot
	if Input.is_action_pressed("shoot"):
		shoot()


func shoot():
	if not can_control:
		return

	if is_reloading:
		return

	if cooldown_timer > 0.0:
		return

	if current_ammo <= 0:
		reload()
		return

	var bullet = bullet_scene.instantiate()

	get_tree().current_scene.add_child(bullet)

	bullet.global_position = bullet_spawn.global_position

	current_ammo -= 1

	cooldown_timer = shoot_cooldown

	update_ammo_display()

	if current_ammo <= 0:
		reload()


func reload():
	if is_reloading:
		return

	is_reloading = true

	update_ammo_display()

	await get_tree().create_timer(reload_time).timeout

	if not is_inside_tree():
		return

	current_ammo = max_ammo

	is_reloading = false

	update_ammo_display()


func update_ammo_display():
	if ammo_label == null:
		return

	if is_reloading:
		ammo_label.text = "RELOADING..."
		ammo_label.modulate = Color.RED
	else:
		ammo_label.text = str(current_ammo) + "/" + str(max_ammo)
		ammo_label.modulate = Color.WHITE
