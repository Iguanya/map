extends CharacterBody3D

@onready var camera_mount = $cameramount
@onready var animation_player = $visuals/mixamo_base/AnimationPlayer
@onready var visuals = $visuals
@onready var synchronizer = $MultiplayerSynchronizer

const SPEED = 2.0
const JUMP_VELOCITY = 3

@export var sens_horizontal = 0.25
@export var sens_vertical = 0.1
@export var rotation_speed = 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var vertical_angle = 0.0
const MAX_VERTICAL_ANGLE = 45.0
const MIN_VERTICAL_ANGLE = -45.0

var can_interact = false
var interaction_target = null

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("Player ready.")
	if synchronizer:
		print("MultiplayerSynchronizer initialized successfully.")
	else:
		print("MultiplayerSynchronizer not found.")

func _input(event):
	if has_multiplayer_authority():
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))

			vertical_angle -= event.relative.y * sens_vertical
			vertical_angle = clamp(vertical_angle, MIN_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
			camera_mount.rotation.x = deg_to_rad(vertical_angle)

		elif event is InputEventKey and event.pressed:
			if event.physical_keycode == KEY_E:  # Physical 'E' key for interaction
				if can_interact and interaction_target:
					interaction_target.interact()

func _physics_process(delta):
	if has_multiplayer_authority():
		if not is_on_floor():
			velocity.y -= gravity * delta

		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var input_dir = Vector3(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			0,
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		)

		var direction = (global_transform.basis * input_dir).normalized()

		if direction != Vector3.ZERO:
			if animation_player.current_animation != "walking":
				animation_player.play("walking")
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			if animation_player.current_animation != ("idle"):
				animation_player.play("idle")
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.z = move_toward(velocity.z, 0, SPEED * delta)

		move_and_slide()

func has_multiplayer_authority() -> bool:
	return multiplayer.is_server() or synchronizer.is_multiplayer_authority()
