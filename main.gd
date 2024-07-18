extends Node

@export var player_scenes: Array[PackedScene]
var players = {}
var available_ids = [1, 2, 3, 4, 5, 6, 7, 8]
var current_scene_index = 0
var network_id_to_player_id = {}

signal player_spawned(id, player)

func _ready():
	print("MultiplayerSpawner ready.")
	multiplayer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	multiplayer.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))

	for id in multiplayer.get_peers():
		if id != multiplayer.get_unique_id():
			spawn_player(id)
	spawn_player(multiplayer.get_unique_id())

func get_unique_id():
	if available_ids.size() > 0:
		var random_index = randi() % available_ids.size()
		return available_ids[random_index]
	else:
		print("No available IDs.")
		return -1

func get_next_player_scene():
	var scene = player_scenes[current_scene_index % player_scenes.size()]
	current_scene_index += 1
	return scene

func spawn_player(network_id):
	if network_id in players:
		print("Player with Network ID already spawned: ", network_id)
		return null

	print("Attempting to spawn player with Network ID: ", network_id)

	if player_scenes.size() == 0:
		print("Player scenes not set.")
		return null

	var player_id = get_unique_id()
	if player_id == -1:
		print("No available player IDs.")
		return null

	network_id_to_player_id[network_id] = player_id

	var player_scene = get_next_player_scene()
	var player_instance = player_scene.instantiate()
	if not player_instance:
		print("Failed to instantiate player scene.")
		return null

	player_instance.name = str(player_id)
	add_child(player_instance)
	players[network_id] = player_instance
	available_ids.erase(player_id)
	print("Player spawned with Network ID: ", network_id, " and Player ID: ", player_id)
	emit_signal("player_spawned", player_id, player_instance)
	return player_instance

func remove_player(network_id):
	print("Attempting to remove player with Network ID: ", network_id)
	if network_id in players:
		var player_id = network_id_to_player_id[network_id]
		players[network_id].queue_free()
		players.erase(network_id)
		network_id_to_player_id.erase(network_id)
		available_ids.append(player_id)
		print("Player removed with Network ID: ", network_id, " and Player ID: ", player_id)
	else:
		print("Network ID not found in players dictionary.")

func _on_peer_connected(id):
	if id != multiplayer.get_unique_id():
		print("Peer connected with Network ID:", id)
		spawn_player(id)

func _on_peer_disconnected(id):
	print("Peer disconnected with Network ID:", id)
	remove_player(id)
