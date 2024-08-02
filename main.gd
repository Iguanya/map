extends Node

var BlockchainClass = preload("res://chain/scripts/Blockchain.gd")
var TransactionClass = preload("res://chain/scripts/Transaction.gd")
var PrioritySettingScreen = preload("res://SettingPriorities.tscn")

@onready var blockchain_instance = BlockchainClass.new()
@export var player_scenes: Array[PackedScene]
var players = {}
var available_ids = [1, 2, 3, 4, 5, 6, 7, 8]
var current_scene_index = 0
var network_id_to_player_id = {}

signal player_spawned(id, player)
signal balance_updated(network_id, balance)
signal priority_selected(player_id, priorities)

func _ready():
	if blockchain_instance.chain.size() == 0:
		blockchain_instance.chain.append(blockchain_instance.create_genesis_block())
	print("Blockchain initialized.")
	multiplayer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	multiplayer.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))

	for id in multiplayer.get_peers():
		if id != multiplayer.get_unique_id():
			spawn_player(id)
	spawn_player(multiplayer.get_unique_id())

	start_random_priority_timer()

func get_unique_id():
	if available_ids.size() > 0:
		var random_index = randi() % available_ids.size()
		return available_ids[random_index]
	else:
		print("No available IDs.")
		return -1

func get_next_player_scene():
	if player_scenes.size() == 0:
		print("Error: No player scenes available.")
		return null
	var scene = player_scenes[current_scene_index % player_scenes.size()]
	current_scene_index += 1
	return scene

func spawn_player(network_id):
	if network_id in players:
		print("Player with Network ID already spawned: ", network_id)
		return null

	print("Attempting to spawn player with Network ID: ", network_id)

	var player_id = get_unique_id()
	if player_id == -1:
		print("No available player IDs.")
		return null

	network_id_to_player_id[network_id] = player_id

	var player_scene = get_next_player_scene()
	if player_scene == null:
		print("Failed to get player scene.")
		return null
	
	var player_instance = player_scene.instantiate()
	if not player_instance:
		print("Failed to instantiate player scene.")
		return null

	player_instance.name = str(player_id)
	add_child(player_instance)
	players[network_id] = player_instance
	available_ids.erase(player_id)
	print("Player spawned with Network ID: ", network_id, " and Player ID: ", player_id)

	# Check and grant initial balance
	var player_balance = blockchain_instance.get_balance_of_address(str(network_id))
	if player_balance == 0:
		var transaction = TransactionClass.new("Treasurer", str(network_id), 100000)
		blockchain_instance.add_transaction(transaction)

	player_balance = blockchain_instance.get_balance_of_address(str(network_id))
	print("Updated coin value for network_id: ", network_id, ":", player_balance)
	emit_signal("balance_updated", network_id, player_balance)

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

# Function to allocate DBS to a player and include it in the blockchain
func allocate_dbs_to_player(network_id: String, amount: int):
	if blockchain_instance == null:
		print("Blockchain instance not found.")
		return
	
	# Check the current balance
	var current_balance = blockchain_instance.get_balance_of_address("Treasurer")
	print("Current DBS balance in the blockchain: ", current_balance)
	
	# Ensure enough balance is available
	if current_balance < amount:
		print("Not enough DBS available to allocate ", amount, " DBS. Minting additional DBS.")
		mint_additional_dbs(amount - current_balance)
	
	# Show balance before transaction
	print("Balance before transaction for player ", network_id, ": ", blockchain_instance.get_balance_of_address(network_id))

	# Create and add the transaction
	var transaction = TransactionClass.new("Treasurer", network_id, amount)
	blockchain_instance.add_transaction(transaction)
	
	# Mine the block containing the transaction
	mine_pending_transactions()
	
	# Update the player's balance
	var player_balance = blockchain_instance.get_balance_of_address(network_id)
	print("Updated coin value for network_id: ", network_id, ":", player_balance)
	emit_signal("balance_updated", network_id, player_balance)

	# Show balance after transaction
	print("Balance after transaction for player ", network_id, ": ", blockchain_instance.get_balance_of_address(network_id))

# Function to mint additional DBS
func mint_additional_dbs(amount: int):
	var transaction = TransactionClass.new("System", "Treasurer", amount)
	blockchain_instance.add_transaction(transaction)
	mine_pending_transactions()

# Function to mine pending transactions
func mine_pending_transactions():
	var miner_address = "Treasurer"
	blockchain_instance.mine_pending_transactions(miner_address)

	# Update balances for all players
	for network_id in players.keys():
		var player_balance = blockchain_instance.get_balance_of_address(str(network_id))
		emit_signal("balance_updated", network_id, player_balance)

# Random priority setting trigger
func start_random_priority_timer():
	var timer = Timer.new()
	timer.wait_time = randf_range(30.0, 60.0) # Random time between 30 to 60 seconds
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_random_priority_timer_timeout"))
	add_child(timer)
	timer.start()

# Function called when the random priority timer times out
func _on_random_priority_timer_timeout():
	show_priority_screen()

# Function to show the priority setting screen
func show_priority_screen():
	var priority_screen_instance = PrioritySettingScreen.instantiate()
	add_child(priority_screen_instance)
	priority_screen_instance.connect("priority_selected", Callable(self, "_on_priority_selected"))

# Function called when priorities are selected
func _on_priority_selected(player_id, priorities):
	print("Player ", player_id, " selected priorities: ", priorities)
	# You can add further logic here to handle the selected priorities



