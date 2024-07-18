extends CharacterBody3D

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5
@export var speed = 5.0
@export var jump_velocity = 4.5

@onready var camera_mount = $cameramount
@onready var animation_player = $visuals/mixamo_base/AnimationPlayer
@onready var synchronizer = $MultiplayerSynchronizer  # Reference the MultiplayerSynchronizer node

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

func _physics_process(delta):
	if has_multiplayer_authority():
		# Apply gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_velocity

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
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
			velocity.x = move_toward(velocity.x, 0, speed * delta)
			velocity.z = move_toward(velocity.z, 0, speed * delta)

		# Apply movement and collision handling
		move_and_slide()

func has_multiplayer_authority() -> bool:
	return multiplayer.is_server() or synchronizer.is_multiplayer_authority()
