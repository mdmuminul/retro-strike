extends Node2D


var enemy_scene = preload(
	"res://scenes/enemy/enemy.tscn"
)


@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer


func _ready():

	enemy_spawn_timer.timeout.connect(
		_spawn_enemy
	)

	_set_random_spawn_time()


func _spawn_enemy():

	var enemy = enemy_scene.instantiate()

	add_child(enemy)


	# Random horizontal position
	var random_x = randf_range(
		60.0,
		get_viewport_rect().size.x - 60.0
	)


	# Spawn completely outside the top of the screen
	enemy.position = Vector2(
		random_x,
		-120.0
	)


	# Randomize when the next alien appears
	_set_random_spawn_time()


func _set_random_spawn_time():

	enemy_spawn_timer.wait_time = randf_range(
		1.2,
		2.0
	)
