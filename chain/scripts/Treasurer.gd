extends Control

@export var blockchain: NodePath
@onready var minted_money_label = $MintedMoneyLabel
@onready var proceedings = $proceedings  # Reference to the RichTextLabel
@onready var mint_button = $VBoxContainer/MintButton
@onready var save_button = $VBoxContainer/SaveButton
@onready var load_button = $VBoxContainer/LoadButton
@onready var visualize_button = $VBoxContainer/VisualizeButton

var total_minted_money: int = 0
var blockchain_instance: Blockchain = null
var game_treasury: int = 1004  # Total DBS 1,125,000
var minting: bool = false

func _ready():
	print("Treasurer is ready.")
	print("Blockchain path: ", blockchain)  # Debugging print
	mint_button.connect("pressed", Callable(self, "_on_mint_button_pressed"))
	save_button.connect("pressed", Callable(self, "_on_save_button_pressed"))
	load_button.connect("pressed", Callable(self, "_on_load_button_pressed"))
	visualize_button.connect("pressed", Callable(self, "_on_visualize_button_pressed"))
	
	blockchain_instance = get_node(blockchain) as Blockchain
	if blockchain_instance == null:
		print("Blockchain instance not found at path: ", blockchain)
		return
	print("Blockchain instance found.")
	proceedings.append_text("Blockchain initialized and ready.\n")
	proceedings.append_text("Game Treasury: " + str(game_treasury) + " DBS\n")

func _on_mint_button_pressed():
	if not minting:
		minting = true
		proceedings.append_text("Minting process started.\n")
		await _mint_coins()

func _mint_coins() -> void:
	while total_minted_money < game_treasury:
		var transaction = Transaction.new("System", "Treasurer", 1)
		var new_block = Block.new(blockchain_instance.chain.size(), [transaction], blockchain_instance.get_latest_block().block_hash, proceedings)
		blockchain_instance.add_block(new_block)
		total_minted_money += 1
		update_minted_money_label()
		
		if blockchain_instance.is_chain_valid():
			proceedings.append_text("New block minted and blockchain is valid. Total minted money: " + str(total_minted_money) + "\n")
		else:
			proceedings.append_text("Blockchain is invalid!\n")
		
		# Continue minting the next coin
		await get_tree().create_timer(0.1).timeout  # Adjust the timer duration as needed

	minting = false
	proceedings.append_text("Minting process completed. Total minted money: " + str(total_minted_money) + "\n")

func update_minted_money_label():
	minted_money_label.text = str(total_minted_money)

func _on_save_button_pressed():
	print("Save button pressed.")
	proceedings.append_text("Save button pressed.\n")
	if blockchain_instance == null:
		print("Blockchain instance not found.")
		proceedings.append_text("Blockchain instance not found.\n")
		return

	blockchain_instance.save_blockchain("user://blockchain.dat")
	print("Blockchain saved.")
	proceedings.append_text("Blockchain saved.\n")

func _on_load_button_pressed():
	print("Load button pressed.")
	proceedings.append_text("Load button pressed.\n")
	if blockchain_instance == null:
		print("Blockchain instance not found.")
		proceedings.append_text("Blockchain instance not found.\n")
		return

	blockchain_instance.load_blockchain("user://blockchain.dat")
	update_minted_money_label()
	print("Blockchain loaded and UI updated.")
	proceedings.append_text("Blockchain loaded and UI updated.\n")

func _on_visualize_button_pressed():
	print("Visualize button pressed.")
	proceedings.append_text("Visualize button pressed.\n")
	if blockchain_instance == null:
		print("Blockchain instance not found.")
		proceedings.append_text("Blockchain instance not found.\n")
		return

	visualize_blockchain()

func visualize_blockchain():
	if blockchain_instance == null:
		print("Blockchain instance not found.")
		proceedings.append_text("Blockchain instance not found.\n")
		return

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
	proceedings.append_text("Blockchain visualized.\n")
