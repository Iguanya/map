extends Node3D

@export var door_name: String = "Default Door"
@export var is_open: bool = false

@onready var static_body = $Object_6
@onready var area = $Object_6/Area3D

func _ready():
	print("Door script ready for:", door_name)
	print("StaticBody node:", static_body)
	print("Area node:", area)
	
	if area:
		area.connect("body_entered", Callable(self, "_on_body_entered"))
		area.connect("body_exited", Callable(self, "_on_body_exited"))
		print("Connected signals for Area node.")
	else:
		print("Area node not found!")

func _on_body_entered(body):
	print("body_entered signal received. Body:", body)
	if body.is_in_group("players"):
		print("Player entered interaction area for:", door_name)
		body.can_interact = true
		body.interaction_target = self
		show_prompt("You have approached the " + door_name)
	else:
		print("Non-player body entered:", body)

func _on_body_exited(body):
	print("body_exited signal received. Body:", body)
	if body.is_in_group("players"):
		print("Player exited interaction area for:", door_name)
		body.can_interact = false
		body.interaction_target = null
		hide_prompt()
	else:
		print("Non-player body exited:", body)

func interact():
	print("Interact called on:", door_name)
	if is_open:
		close()
	else:
		open()

func open():
	is_open = true
	print(door_name + " opened.")
	static_body.visible = false  # Hide the door to simulate opening it

func close():
	is_open = false
	print(door_name + " closed.")
	static_body.visible = true  # Show the door to simulate closing it

func show_prompt(message: String):
	# Replace with your logic to display the prompt message
	print("Prompt:", message)

func hide_prompt():
	# Replace with your logic to hide the prompt message
	print("Prompt hidden")
