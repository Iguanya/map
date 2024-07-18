extends Control

@export var blockchain: NodePath
@onready var minted_money_label = $MintedMoneyLabel

var total_minted_money: int = 0

func _ready():
	print("Treasurer is ready.")
	print("Blockchain path: ", blockchain)  # Debugging print
	$MintButton.connect("pressed", Callable(self, "_on_mint_button_pressed"))

func _on_mint_button_pressed():
	print("Mint button pressed.")
	var blockchain_instance = get_node(blockchain) as Blockchain
	if blockchain_instance == null:
		print("Blockchain instance not found at path: ", blockchain)
		return
	
	print("Blockchain instance found.")
	var transaction = Transaction.new("Treasurer", "Player", 100)
	var new_block = Block.new(blockchain_instance.chain.size(), [transaction], blockchain_instance.get_latest_block().block_hash)
	blockchain_instance.add_block(new_block)
	
	if blockchain_instance.is_chain_valid():
		total_minted_money += 100
		update_minted_money_label()
		print("New block minted and blockchain is valid. Total minted money: ", total_minted_money)
	else:
		print("Blockchain is invalid!")

func update_minted_money_label():
	minted_money_label.text = str(total_minted_money)
