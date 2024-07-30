# player.gd
extends CharacterBody3D

@onready var camera_mount = $cameramount
@onready var animation_player = $visuals/mixamo_base/AnimationPlayer
@onready var visuals = $visuals
@onready var synchronizer = $MultiplayerSynchronizer

@export var card_manager_path = NodePath("/root/main/CardManager")  # Adjust the path as per your scene structure
@export var maisha_hutokea_path = NodePath("/root/main/MaishaHutokea")

var card_manager
var maisha_hutokea

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

var assigned_cards = []
var balance = 100000 # Example starting balance

signal balance_updated(network_id: String, balance: int)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("Player ready.")
	if synchronizer:
		print("MultiplayerSynchronizer initialized successfully.")
	else:
		print("MultiplayerSynchronizer not found.")

	# Find the CardManager and MaishaHutokea nodes
	card_manager = get_node_or_null(card_manager_path)
	maisha_hutokea = get_node_or_null(maisha_hutokea_path)

	if not card_manager:
		print("CardManager not found at path: ", card_manager_path)
	else:
		print("CardManager found.")

	if not maisha_hutokea:
		print("MaishaHutokea not found at path: ", maisha_hutokea_path)
	else:
		print("MaishaHutokea found.")
		maisha_hutokea.connect("card_assigned", Callable(self, "_on_card_assigned"))

	# Example of assigning a card to the player when ready
	if card_manager:
		assign_new_card()

	# Setup the timer for randomizing cards
	var timer = Timer.new()
	timer.wait_time = 30  # 300 seconds = 5 minutes
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	add_child(timer)
	timer.start()

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
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.z = move_toward(velocity.z, 0, SPEED * delta)

		move_and_slide()

func has_multiplayer_authority() -> bool:
	return multiplayer.is_server() or synchronizer.is_multiplayer_authority()

func assign_card(card):
	assigned_cards.append(card)
	handle_card_impact(card)
	if maisha_hutokea:
		maisha_hutokea.update_card(card)  # Update the UI with the new card

func handle_card_impact(card):
	if card["type"] == "profit":
		balance += card["impact"]
	elif card["type"] == "expense":
		if card.has("condition") and has_item(card["condition"]):
			balance += card["reduced_impact"]
		else:
			balance += card["impact"]
	emit_signal("balance_updated", "1", balance)  # Replace "1" with actual player ID logic
	# Handle other card types as needed

func has_item(_item_name):
	# Check if the player has a specific item (e.g., safety ladder, first-aid-kit)
	# This function needs to be implemented based on your game's inventory system
	return false

func assign_new_card():
	if card_manager:
		card_manager.assign_random_card_to_player(self)

func _on_Timer_timeout():
	assign_new_card()

func _on_card_assigned(card):
	print("Card assigned: ", card)
