extends Area2D

@export var min_speed: float = 70.0
@export var max_speed: float = 110.0

@onready var sprite: Sprite2D = $Sprite2D

var enemy_textures = [
	preload("res://assets/enemies/alien_red.png"),
	preload("res://assets/enemies/alien_bug.png"),
	preload("res://assets/enemies/alien_jelly.png"),
	preload("res://assets/enemies/alien_armored.png")
]

var speed: float


func _ready():

	sprite.texture = enemy_textures.pick_random()

	speed = randf_range(
		min_speed,
		max_speed
	)

	area_entered.connect(_on_area_entered)


func _physics_process(delta):

	position.y += speed * delta

	if position.y > 650:
		queue_free()


func _on_area_entered(area):

	if area.is_in_group("bullet"):

		area.queue_free()

		queue_free()
