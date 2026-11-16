extends Sprite2D

@export var move_speed: float = 20.0
@export var rotation_speed: float = 0.1

var screen_width: float

func _ready():
	screen_width = get_viewport_rect().size.x

func _process(delta):
	position.x += move_speed * delta
	rotation += rotation_speed * delta

	if position.x > screen_width + 100:
		position.x = -100
