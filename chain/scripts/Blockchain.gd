extends Node

class_name Blockchain

var chain: Array
var difficulty: int = 2  # Simplified for fast minting
var total_dbs: int = 10000  # Initial DBS amount, adjust if needed

func _ready():
	chain = []
	if chain.size() == 0:
		chain.append(create_genesis_block())
		print("Genesis block created.")

func create_genesis_block() -> Block:
	var genesis_block = Block.new(0, [], "0", "")
	genesis_block.block_hash = genesis_block.calculate_hash()
	return genesis_block

func get_latest_block() -> Block:
	if chain.size() == 0:
		return create_genesis_block()
	return chain[-1]

func add_block(new_block: Block):
	new_block.previous_hash = get_latest_block().block_hash
	new_block.mine_block(difficulty)
	chain.append(new_block)
	print("Block added to the blockchain. Current chain length: ", chain.size())

func is_chain_valid() -> bool:
	for i in range(1, chain.size()):
		var current_block = chain[i]
		var previous_block = chain[i - 1]

		if current_block.block_hash != current_block.calculate_hash():
			return false

		if current_block.previous_hash != previous_block.block_hash:
			return false

	return true

func save_blockchain(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_var(chain)
		file.close()
		print("Blockchain saved to ", file_path)
	else:
		print("Failed to open file for writing: ", file_path)

func load_blockchain(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("File not found: ", file_path)
		return
	var file_content = file.get_as_text()
	var chain_data = JSON.parse_string(file_content)
	
	# Check for parsing errors
	if typeof(chain_data) != TYPE_ARRAY:
		print("Failed to parse JSON: ", file_content)
		return

	chain = []
	for block_dict in chain_data:
		var block = Block.new(block_dict["index"], block_dict["transactions"], block_dict["previous_hash"], "")
		block.from_dict(block_dict)
		chain.append(block)
	file.close()
	print("Blockchain loaded successfully.")

func get_total_dbs() -> int:
	var accumulated_dbs = 0  # Renamed to avoid conflict
	for block in chain:
		for transaction in block.transactions:
			accumulated_dbs += transaction.amount
	return accumulated_dbs


func get_balance_of_address(address: String) -> int:
	var balance = 0
	for block in chain:
		for transaction in block.transactions:
			if transaction.recipient == address:
				balance += transaction.amount
			if transaction.sender == address:
				balance -= transaction.amount
	return balance

func add_transaction(transaction: Transaction):
	# Check if the sender has enough balance
	var sender_balance = get_balance_of_address(transaction.sender)
	if sender_balance < transaction.amount:
		print("Insufficient balance for transaction.")
		return
	
	# Add transaction to the blockchain
	var new_block = Block.new(chain.size(), [transaction], get_latest_block().block_hash, "")
	add_block(new_block)

func mine_pending_transactions(miner_address: String):
	# Simulate mining process and reward the miner
	var reward_transaction = Transaction.new("System", miner_address, 50)  # Reward for mining
	var new_block = Block.new(chain.size(), [reward_transaction], get_latest_block().block_hash, "")
	add_block(new_block)
