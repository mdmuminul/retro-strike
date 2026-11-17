extends Node2D

var enemy_scene = preload(
	"res://scenes/enemy/enemy.tscn"
)

@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var player = $Player

@onready var score_label: Label = $UI/ScoreLabel

@onready var heart1: TextureRect = $"UI/Heart 1"
@onready var heart2: TextureRect = $"UI/Heart 2"
@onready var heart3: TextureRect = $"UI/Heart 3"

@onready var game_over_panel = $UI/GameOverPanel

@onready var final_score_label: Label = (
	$UI/GameOverPanel/FinalScoreLabel
)

@onready var restart_button: Button = (
	$UI/GameOverPanel/RestartButton
)

var score: int = 0
var lives: int = 3
var game_over: bool = false


func _ready():
	enemy_spawn_timer.timeout.connect(_spawn_enemy)
	restart_button.pressed.connect(_restart_game)

	game_over_panel.hide()

	update_ui()

	_set_random_spawn_time()


func _spawn_enemy():
	if game_over:
		return

	var enemy = enemy_scene.instantiate()

	add_child(enemy)

	var random_x := randf_range(
		60.0,
		get_viewport_rect().size.x - 60.0
	)

	enemy.position = Vector2(
		random_x,
		-120.0
	)

	enemy.destroyed.connect(
		_on_enemy_destroyed
	)

	enemy.hit_player.connect(
		_on_enemy_hit_player
	)

	_set_random_spawn_time()


func _set_random_spawn_time():
	enemy_spawn_timer.wait_time = randf_range(
		1.2,
		2.0
	)


func _on_enemy_destroyed(points):
	if game_over:
		return

	score += points

	update_ui()


func _on_enemy_hit_player():
	if game_over:
		return

	lives -= 1

	if lives < 0:
		lives = 0

	update_ui()

	if lives <= 0:
		end_game()


func update_ui():
	score_label.text = (
		"SCORE "
		+ str(score).pad_zeros(4)
	)

	update_lives_display()


func update_lives_display():
	heart1.visible = lives >= 1
	heart2.visible = lives >= 2
	heart3.visible = lives >= 3


func end_game():
	game_over = true

	enemy_spawn_timer.stop()

	player.can_control = false

	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.set_physics_process(false)

	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.set_physics_process(false)

	final_score_label.text = (
		"FINAL SCORE "
		+ str(score).pad_zeros(4)
	)

	game_over_panel.show()


func _restart_game():
	get_tree().reload_current_scene()
