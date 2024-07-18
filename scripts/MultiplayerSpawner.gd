extends Node

@export var player_scene: PackedScene
var players = {}

signal player_spawned(id, player)

@onready var multispawner = $MultiplayerSpawner

func _ready():
	print("MultiplayerSpawner ready.")
	set_process(true)

	for id in multiplayer.get_peers():
		if id != multiplayer.get_unique_id():
			spawn_player(id)

	multiplayer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	multiplayer.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
	
	# Automatically spawn the local player if this is the server
	if multiplayer.is_server():
		spawn_player(multiplayer.get_unique_id())

func spawn_player(id):
	print("Attempting to spawn player with ID: ", id)
	
	if not player_scene:
		print("Player scene not set.")
		return null
	
	var player_instance = player_scene.instantiate()
	if not player_instance:
		print("Failed to instantiate player scene.")
		return null
	
	player_instance.name = str(id)
	add_child(player_instance)
	players[id] = player_instance
	print("Player spawned with ID: ", id)
	emit_signal("player_spawned", id, player_instance)
	return player_instance

func remove_player(id):
	print("Attempting to remove player with ID: ", id)
	if id in players:
		players[id].queue_free()
		players.erase(id)
		print("Player removed with ID: ", id)
	else:
		print("Player ID not found in players dictionary.")

func _on_peer_connected(id):
	print("Peer connected with ID:", id)
	spawn_player(id)

func _on_peer_disconnected(id):
	print("Peer disconnected with ID:", id)
	remove_player(id)
