extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var animation_player = $visuals/skibidi/AnimationPlayer
@onready var visuals = $visuals/skibidi
@onready var synchronizer = $MultiplayerSynchronizer  # Reference the MultiplayerSynchronizer node

const SPEED = 2.0
const JUMP_VELOCITY = 3

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5
@export var rotation_speed = 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("Player ready.")
	if synchronizer:
		print("MultiplayerSynchronizer initialized successfully.")
	else:
		print("MultiplayerSynchronizer not found.")

func _input(event):
	if has_multiplayer_authority() and event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	if has_multiplayer_authority():
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
			animation_player.play("mixamo_com")
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.z = move_toward(velocity.z, 0, SPEED * delta)

		# Apply movement and collision handling
		move_and_slide()

func has_multiplayer_authority() -> bool:
	return multiplayer.is_server() or synchronizer.is_multiplayer_authority()
