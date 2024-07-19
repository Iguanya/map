extends Control

@export var blockchain: NodePath
@onready var minted_money_label = $MintedMoneyLabel
@onready var mint_button = $VBoxContainer/MintButton
@onready var save_button = $VBoxContainer/SaveButton
@onready var load_button = $VBoxContainer/LoadButton
@onready var visualize_button = $VBoxContainer/VisualizeButton
@onready var proceedings = $proceedings

var total_minted_money: int = 0
var minting_process_active: bool = false
var difficulty: int = 3  # Adjust the difficulty level as needed

func _ready():
	print("Treasurer is ready.")
	print("Blockchain path: ", blockchain)
	mint_button.connect("pressed", Callable(self, "_on_mint_button_pressed"))
	save_button.connect("pressed", Callable(self, "_on_save_button_pressed"))
	load_button.connect("pressed", Callable(self, "_on_load_button_pressed"))
	visualize_button.connect("pressed", Callable(self, "_on_visualize_button_pressed"))

	var blockchain_instance = get_node(blockchain) as Blockchain
	if blockchain_instance == null:
		print("Blockchain instance not found at path: ", blockchain)
		return
	print("Blockchain instance found.")

func _on_mint_button_pressed():
	if not minting_process_active:
		minting_process_active = true
		_start_minting()

func _start_minting():
	var blockchain_instance = get_node(blockchain) as Blockchain
	if blockchain_instance == null:
		print("Blockchain instance not found at path: ", blockchain)
		return

	async_mint(blockchain_instance)

func async_mint(blockchain_instance):
	while total_minted_money < 1000:
		var transaction = Transaction.new("Treasurer", "Player", 1)
		var new_block = Block.new(blockchain_instance.chain.size(), [transaction], blockchain_instance.get_latest_block().block_hash)

		var start_time = Utils.get_unix_time()
		new_block.mine_block(difficulty)  # Mine the block with the given difficulty
		var end_time = Utils.get_unix_time()
		var elapsed_time = end_time - start_time

		blockchain_instance.add_block(new_block)

		if blockchain_instance.is_chain_valid():
			total_minted_money += 1
			update_minted_money_label()
			update_proceedings_label("Minted 1 DBS. Hash: " + new_block.block_hash + ". Elapsed time: " + str(elapsed_time) + " seconds. Total minted money: " + str(total_minted_money))
			print("New block minted and blockchain is valid. Total minted money: ", total_minted_money)
		else:
			print("Blockchain is invalid!")
			break

		await get_tree().create_timer(0.1).timeout

	minting_process_active = false

func update_minted_money_label():
	minted_money_label.text = str(total_minted_money)

func update_proceedings_label(text):
	proceedings.text += text + "\n"

func _on_save_button_pressed():
	print("Save button pressed.")
	var blockchain_instance = get_node(blockchain) as Blockchain
	if blockchain_instance == null:
		print("Blockchain instance not found at path: ", blockchain)
		return

	blockchain_instance.save_blockchain("user://blockchain.dat")
	print("Blockchain saved.")

func _on_load_button_pressed():
	print("Load button pressed.")
	var blockchain_instance = get_node(blockchain) as Blockchain
	if blockchain_instance == null:
		print("Blockchain instance not found at path: ", blockchain)
		return

	blockchain_instance.load_blockchain("user://blockchain.dat")
	update_minted_money_label()
	print("Blockchain loaded and UI updated.")
	
	# Get total DBS
	var total_dbs = blockchain_instance.get_total_dbs()
	print("Total DBS: ", total_dbs)
	minted_money_label.text = str(total_dbs)


func _on_visualize_button_pressed():
	print("Visualize button pressed.")
	var blockchain_instance = get_node(blockchain) as Blockchain
	if blockchain_instance == null:
		print("Blockchain instance not found at path: ", blockchain)
		return

	visualize_blockchain()

func visualize_blockchain():
	var blockchain_instance = get_node(blockchain) as Blockchain
	var visualization_text = "Blockchain:\n"
	for block in blockchain_instance.chain:
		visualization_text += "Block " + str(block.index) + ":\n"
		visualization_text += " Previous Hash: " + block.previous_hash + "\n"
		visualization_text += " Transactions: \n"
		for transaction in block.transactions:
			visualization_text += "  " + transaction.sender + " -> " + transaction.recipient + ": " + str(transaction.amount) + "\n"
		visualization_text += " Hash: " + block.block_hash + "\n\n"

	var popup = Popup.new()
	add_child(popup)
	var label = Label.new()
	label.text = visualization_text
	popup.add_child(label)
	popup.popup_centered()
