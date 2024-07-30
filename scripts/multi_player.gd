extends CanvasLayer

var peer = ENetMultiplayerPeer.new()
@export var max_players = 8
@onready var host_button = $Host
@onready var join_button = $Join
@onready var multispawner = $spawner
@onready var blockchain = $"../Blockchain"  # Make sure this path is correct
var num_instances = 0

signal server_created
signal joined_server
signal player_connected(id)
signal player_disconnected(id)

var minting = false

func _ready():
	print("MultiPlayer ready")
	if not host_button.is_connected("pressed", Callable(self, "_on_host_pressed")):
		host_button.connect("pressed", Callable(self, "_on_host_pressed"))
	if not join_button.is_connected("pressed", Callable(self, "_on_join_pressed")):
		join_button.connect("pressed", Callable(self, "_on_join_pressed"))

	if not is_connected("server_created", Callable(self, "_on_server_created")):
		connect("server_created", Callable(self, "_on_server_created"))
	if not is_connected("joined_server", Callable(self, "_on_joined_server")):
		connect("joined_server", Callable(self, "_on_joined_server"))
	if not is_connected("player_connected", Callable(self, "_on_player_connected")):
		connect("player_connected", Callable(self, "_on_player_connected"))
	if not is_connected("player_disconnected", Callable(self, "_on_player_disconnected")):
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
	# Update player balance after spawning
	call_deferred("distribute_coins", multiplayer.get_unique_id())
	# Start minting process if not already started

func _on_joined_server():
	print("Joined server in main scene.")
	$Host.hide()
	$Join.hide()
	if multispawner:
		multispawner.spawn_player(multiplayer.get_unique_id())
	# Update player balance after spawning
	#call_deferred("distribute_coins", multiplayer.get_unique_id())

func _on_player_connected(id):
	print("Player connected with ID: ", id)
	if multispawner:
		multispawner.spawn_player(id)
	# Update player balance after spawning
	#call_deferred("distribute_coins", id)

func _on_player_disconnected(id):
	print("Player disconnected with ID: ", id)
	if multispawner:
		multispawner.remove_player(id)

# New function to distribute coins to players
#func distribute_coins(player_id, amount = 1000):
#	if blockchain == null:
#		print("Blockchain instance not found.")
#		return

#	var transaction = Transaction.new("Treasurer", str(player_id), amount)
#	var new_block = Block.new(blockchain.chain.size(), [transaction], blockchain.get_latest_block().block_hash, "")
#	blockchain.add_block(new_block)
#	update_player_balance(player_id)

# Function to update player balance
func update_player_balance(player_id):
	if blockchain == null:
		print("Blockchain instance not found.")
		return

	var player_balance = blockchain.get_balance_of_address(str(player_id))
	print("Updated balance for player: ", player_id, " is ", player_balance)
	emit_signal("balance_updated", player_id, player_balance)

# Function to mint coins
#func mint_coins():
#	while true:
#		if blockchain == null:
#			print("Blockchain instance not found.")
#			return
#		
#		var transaction = Transaction.new("Treasurer", "Treasury", 1)
#		var new_block = Block.new(blockchain.chain.size(), [transaction], blockchain.get_latest_block().block_hash, "")
#		blockchain.add_block(new_block)
		
#		print("Minted coin. Total DBS: ", blockchain.get_total_dbs())
		
#		# Stop minting if players are connected
#		if multiplayer.get_peer_count() > 0:
#			print("Players connected, stopping minting.")
#			minting = false
#			break
#		
#		await get_tree().create_timer(1.0).timeout
