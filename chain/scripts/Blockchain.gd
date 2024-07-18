extends Node

class_name Blockchain

var chain: Array
var difficulty: int = 4  # Simplified for fast minting

func _ready():
	chain = []
	chain.append(create_genesis_block())
	print("Genesis block created.")

func create_genesis_block() -> Block:
	var genesis_transaction = Transaction.new("System", "Genesis", 0)
	return Block.new(0, [genesis_transaction], "0", null)  # Pass null for proceedings

func get_latest_block() -> Block:
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
	if file:
		chain = file.get_var()
		file.close()
		print("Blockchain loaded from ", file_path)
	else:
		print("No blockchain file found at ", file_path)
