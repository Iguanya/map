extends CanvasLayer

var peer = ENetMultiplayerPeer.new()
@export var max_players = 8
@onready var host_button = $Host
@onready var join_button = $Join
@onready var multispawner = $spawner
var num_instances = 0

signal server_created
signal joined_server
signal player_connected(id)
signal player_disconnected(id)

func _ready():
	print("MultiPlayer ready")
	host_button.connect("pressed", Callable(self, "_on_host_pressed"))
	join_button.connect("pressed", Callable(self, "_on_join_pressed"))

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
	call_deferred("switch_to_main_scene")

func join_server():
	var result = peer.create_client("127.0.0.1", 1287)
	if result != OK:
		print("Couldn't create an ENet client: ", result)
		return
	print("Joined server successfully.")
	multiplayer.multiplayer_peer = peer
	emit_signal("joined_server")
	call_deferred("switch_to_main_scene")

func switch_to_main_scene():
	var main_scene_path = "res://main.tscn"
	var main_scene = load(main_scene_path)
	print("Loading main scene from path: ", main_scene_path)
	if main_scene:
		print("Main scene loaded successfully.")
		get_tree().change_scene_to_packed(main_scene)
	else:
		print("Failed to load main scene.")

func _on_server_created():
	print("Server created in main scene.")
	$Host.hide()
	$Join.hide()
	if multispawner:
		multispawner.spawn_player(multiplayer.get_unique_id())

func _on_joined_server():
	print("Joined server in main scene.")
	$Host.hide()
	$Join.hide()
	if multispawner:
		multispawner.spawn_player(multiplayer.get_unique_id())

func _on_player_connected(id):
	print("Player connected with ID: ", id)
	if multispawner:
		multispawner.spawn_player(id)

func _on_player_disconnected(id):
	print("Player disconnected with ID: ", id)
	if multispawner:
		multispawner.remove_player(id)
