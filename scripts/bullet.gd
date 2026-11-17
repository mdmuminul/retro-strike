extends Area2D

@export var speed: float = 550.0


func _ready():

	add_to_group("bullet")


func _physics_process(delta):

	position.y -= speed * delta

	if position.y < -100:
		queue_free()
