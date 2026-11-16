extends CharacterBody2D


# -----------------------------
# PLAYER SETTINGS
# -----------------------------

@export var speed: float = 300.0


# -----------------------------
# SHOOTING SETTINGS
# -----------------------------

@export var shoot_cooldown: float = 0.25
@export var max_ammo: int = 25
@export var reload_time: float = 2.0


# -----------------------------
# NODES
# -----------------------------

@onready var bullet_spawn: Marker2D = $BulletSpawn


# -----------------------------
# VARIABLES
# -----------------------------

var screen_size: Vector2

var current_ammo: int

var is_reloading: bool = false

var cooldown_timer: float = 0.0

var ammo_label: Label

var mobile_controls: Control
var fire_button: TextureButton


# -----------------------------
# BULLET SCENE
# -----------------------------

var bullet_scene = preload(
	"res://scenes/bullet/bullet.tscn"
)


# -----------------------------
# READY
# -----------------------------

func _ready():

	screen_size = get_viewport_rect().size

	current_ammo = max_ammo


	# Ammo label
	ammo_label = get_tree().current_scene.get_node_or_null(
		"UI/AmmoLabel"
	)


	# Mobile control container
	mobile_controls = get_tree().current_scene.get_node_or_null(
		"UI/MobileControls"
	)


	# Fire button
	fire_button = get_tree().current_scene.get_node_or_null(
		"UI/MobileControls/FireButton"
	)


	# Connect mobile fire button
	if fire_button != null:
		fire_button.button_down.connect(
			_on_fire_button_pressed
		)


	update_ammo_display()


# -----------------------------
# MAIN LOOP
# -----------------------------

func _physics_process(delta):


	# Shooting cooldown
	if cooldown_timer > 0.0:
		cooldown_timer -= delta


	# -----------------------------
	# KEYBOARD MOVEMENT
	# -----------------------------

	var input_direction := Vector2(
		Input.get_axis(
			"move_left",
			"move_right"
		),

		Input.get_axis(
			"move_up",
			"move_down"
		)
	)


	# -----------------------------
	# MOBILE JOYSTICK
	# -----------------------------

	var joystick_active := false

	if mobile_controls != null:

		if mobile_controls.joystick_output.length() > 0.1:

			input_direction = (
				mobile_controls.joystick_output
			)

			joystick_active = true


	# -----------------------------
	# MOUSE MOVEMENT
	# -----------------------------

	if not joystick_active:

		if Input.is_mouse_button_pressed(
			MOUSE_BUTTON_LEFT
		):

			var mouse_position := (
				get_global_mouse_position()
			)

			var mouse_direction := (
				mouse_position
				- global_position
			)

			if mouse_direction.length() > 10.0:

				input_direction = (
					mouse_direction.normalized()
				)


	# -----------------------------
	# MOVE PLAYER
	# -----------------------------

	velocity = (
		input_direction.normalized()
		* speed
	)

	move_and_slide()


	# -----------------------------
	# KEEP PLAYER INSIDE SCREEN
	# -----------------------------

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


	# -----------------------------
	# KEYBOARD SHOOTING
	# -----------------------------

	if Input.is_action_pressed("shoot"):
		shoot()


# -----------------------------
# MOBILE FIRE BUTTON
# -----------------------------

func _on_fire_button_pressed():

	shoot()


# -----------------------------
# SHOOT FUNCTION
# -----------------------------

func shoot():


	if is_reloading:
		return


	if cooldown_timer > 0.0:
		return


	if current_ammo <= 0:

		reload()

		return


	# Create bullet
	var bullet = bullet_scene.instantiate()


	get_tree().current_scene.add_child(
		bullet
	)


	bullet.global_position = (
		bullet_spawn.global_position
	)


	# Reduce ammunition
	current_ammo -= 1


	# Start cooldown
	cooldown_timer = shoot_cooldown


	update_ammo_display()


	# Automatic reload
	if current_ammo <= 0:
		reload()


# -----------------------------
# RELOAD
# -----------------------------

func reload():


	if is_reloading:
		return


	is_reloading = true


	update_ammo_display()


	await get_tree().create_timer(
		reload_time
	).timeout


	current_ammo = max_ammo

	is_reloading = false


	update_ammo_display()


# -----------------------------
# AMMO DISPLAY
# -----------------------------

func update_ammo_display():


	if ammo_label == null:
		return


	if is_reloading:


		ammo_label.text = (
			"Bullets: "
			+ str(current_ammo)
			+ "/"
			+ str(max_ammo)
			+ " - RELOADING..."
		)


		ammo_label.modulate = Color.RED


	else:


		ammo_label.text = (
			"Bullets: "
			+ str(current_ammo)
			+ "/"
			+ str(max_ammo)
		)


		ammo_label.modulate = Color.WHITE
