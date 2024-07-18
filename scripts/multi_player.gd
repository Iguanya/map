extends CanvasLayer

var peer = ENetMultiplayerPeer.new()
@export var max_players = 8
@onready var host = $Host
@onready var join = $Join
var players = {}  # Dictionary to hold player instances

signal server_created
signal joined_server
signal player_connected(id)
signal player_disconnected(id)

func _ready():
	# Connect buttons or input actions for hosting and joining
	if not host.is_connected("pressed", Callable(self, "_on_host_pressed")):
		host.connect("pressed", Callable(self, "_on_host_pressed"))
	
	if not join.is_connected("pressed", Callable(self, "_on_join_pressed")):
		join.connect("pressed", Callable(self, "_on_join_pressed"))
	
	# Connect to signals for managing player connections
	connect("server_created", Callable(self, "_on_server_created"))
	connect("joined_server", Callable(self, "_on_joined_server"))
	connect("player_connected", Callable(self, "_on_player_connected"))
	connect("player_disconnected", Callable(self, "_on_player_disconnected"))

	print("Ready function executed, waiting for host or join.")

func _on_host_pressed():
	print("Host button pressed.")
	create_server()

func _on_join_pressed():
	print("Join button pressed.")
	join_server()

func create_server():
	var result = peer.create_server(1287, max_players)
	if result != OK:
		print("Couldn't create an ENet host: ", result)
		return
	print("Server created successfully.")
	multiplayer.multiplayer_peer = peer
	emit_signal("server_created")
	switch_to_main_scene()

func join_server():
	var result = peer.create_client("127.0.0.1", 1287)
	if result != OK:
		print("Couldn't create an ENet client: ", result)
		return
	print("Joined server successfully.")
	multiplayer.multiplayer_peer = peer
	emit_signal("joined_server")
	switch_to_main_scene()

func switch_to_main_scene():
	var main_scene_path = "res://main.tscn"
	var main_scene = load(main_scene_path)
	if main_scene:
		get_tree().change_scene_to_packed(main_scene)
	else:
		print("Failed to load main scene.")

func _on_server_created():
	print("Server created in main scene.")
	$Host.hide()
	$Join.hide()
	# Spawn the local player
	spawn_local_player()

func _on_joined_server():
	print("Joined server in main scene.")
	$Host.hide()
	$Join.hide()
	# Spawn the local player
	spawn_local_player()

func spawn_local_player():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("spawner"):
		var spawner = main_scene.get_node("spawner")
		if spawner:
			spawner.spawn_player(multiplayer.get_unique_id())
	else:
		print("Spawner node not found in the main scene.")

func _on_player_connected(id):
	print("Player connected with ID: ", id)
	if not players.has(id):
		spawn_player(id)
	emit_signal("player_connected", id)

func _on_player_disconnected(id):
	print("Player disconnected with ID: ", id)
	if players.has(id):
		remove_player(id)
	emit_signal("player_disconnected", id)

func spawn_player(id):
	# Implement the function to spawn a player
	print("Spawning player with ID: ", id)
	# Add your spawn logic here

func remove_player(id):
	# Implement the function to remove a player
	print("Removing player with ID: ", id)
	# Add your removal logic here
