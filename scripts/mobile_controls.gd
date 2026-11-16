extends Control

@export var joystick_radius: float = 60.0

@onready var joystick_base: TextureRect = $JoystickBase
@onready var joystick_knob: TextureRect = $JoystickKnob
@onready var fire_button: TextureButton = $FireButton

var joystick_output: Vector2 = Vector2.ZERO

var active_touch_id: int = -1
var joystick_center: Vector2


func _ready():
	add_to_group("mobile_controls")

	joystick_center = (
		joystick_base.position
		+ joystick_base.size / 2.0
	)

	reset_joystick()


func _input(event):

	# --------------------------------
	# TOUCH START / TOUCH END
	# --------------------------------

	if event is InputEventScreenTouch:

		if event.pressed:

			if active_touch_id == -1:

				if joystick_base.get_global_rect().has_point(event.position):
					active_touch_id = event.index
					update_joystick(event.position)

		else:

			if event.index == active_touch_id:
				active_touch_id = -1
				reset_joystick()


	# --------------------------------
	# TOUCH DRAG
	# --------------------------------

	elif event is InputEventScreenDrag:

		if event.index == active_touch_id:
			update_joystick(event.position)


func update_joystick(touch_position: Vector2):

	var local_touch := touch_position - global_position

	var direction := local_touch - joystick_center

	if direction.length() > joystick_radius:
		direction = direction.normalized() * joystick_radius

	joystick_knob.position = (
		joystick_center
		+ direction
		- joystick_knob.size / 2.0
	)

	joystick_output = direction / joystick_radius


func reset_joystick():

	joystick_output = Vector2.ZERO

	joystick_knob.position = (
		joystick_center
		- joystick_knob.size / 2.0
	)
