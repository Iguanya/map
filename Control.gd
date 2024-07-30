# control.gd

extends Control

@export var blockchain: NodePath
@onready var coins_value = %CoinsValue

signal balance_updated(network_id: String, balance: int)

func _ready():
	print("Control ready.")
	print("Blockchain path: ", blockchain)
	var blockchain_instance = get_node(blockchain) as Blockchain
	if blockchain_instance == null:
		print("Blockchain instance not found at path: ", blockchain)
		return
	update_coin_value("1")  # Replace "1" with the actual player ID logic

	# Connect to the balance_updated signal
	get_tree().connect("balance_updated", Callable(self, "_on_balance_updated"))

func update_coin_value(network_id: String):
	var blockchain_instance = get_node(blockchain) as Blockchain
	if blockchain_instance == null:
		print("Blockchain instance not found at path: ", blockchain)
		return

	var coin_value = blockchain_instance.get_balance_of_address(network_id)
	print("Coin value fetched: ", coin_value)
	coins_value.text = str(coin_value)
	print("Updated coin value for network_id: ", network_id, ": ", coin_value)

func _on_balance_updated(network_id: String, balance: int):
	print("Balance updated for network_id: ", network_id, ": ", balance)
	if str(network_id) == "1":  # Replace "1" with the actual player ID logic
		coins_value.text = str(balance)
