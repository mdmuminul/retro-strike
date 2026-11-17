extends Area2D

signal destroyed(points)
signal hit_player

@export var min_speed: float = 70.0
@export var max_speed: float = 110.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar

var enemy_textures = [
	preload("res://assets/enemies/alien_red.png"),
	preload("res://assets/enemies/alien_bug.png"),
	preload("res://assets/enemies/alien_jelly.png"),
	preload("res://assets/enemies/alien_armored.png")
]

var speed: float

var max_health: int = 1
var health: int = 1

var points: int = 10


func _ready():
	add_to_group("enemy")

	var enemy_type := randi_range(
		0,
		enemy_textures.size() - 1
	)

	sprite.texture = enemy_textures[enemy_type]

	match enemy_type:
		0:
			# Red alien
			max_health = 1
			points = 10

		1:
			# Bug alien
			max_health = 2
			points = 20

		2:
			# Jelly alien
			max_health = 3
			points = 30

		3:
			# Armored alien
			max_health = 5
			points = 50

	health = max_health

	speed = randf_range(
		min_speed,
		max_speed
	)

	# Health bar setup
	health_bar.min_value = 0
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.step = 1
	health_bar.show_percentage = false
	health_bar.show()

	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)


func _physics_process(delta):
	position.y += speed * delta

	if position.y > 650:
		queue_free()


func _on_area_entered(area):
	if area.is_in_group("bullet"):
		# Remove bullet
		area.queue_free()

		# Damage enemy
		health -= 1

		if health < 0:
			health = 0

		# Update health bar
		health_bar.value = health

		# Destroy enemy when HP reaches zero
		if health <= 0:
			destroyed.emit(points)
			queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		hit_player.emit()
		queue_free()
