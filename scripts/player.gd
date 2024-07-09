extends CharacterBody3D

@onready var camera_mount = $cameramount
@onready var animation_player = $visuals/mixamo_base/AnimationPlayer
@onready var visuals = $visuals



const SPEED = 3.0
const JUMP_VELOCITY = 3

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5
@export var rotation_speed = 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))

func _physics_process(delta):
	# Apply gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Vector3(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0,
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	# Transform the direction to be relative to the character's current orientation
	var direction = (global_transform.basis * input_dir).normalized()

	if direction != Vector3.ZERO:
		if animation_player.current_animation != "walking":
			animation_player.play("walking")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta)

	# Apply movement and collision handling
	move_and_slide()
