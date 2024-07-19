extends Node

class_name Blockchain

var chain: Array

func _ready():
	chain = []
	chain.append(create_genesis_block())
	print("Genesis block created.")

func create_genesis_block() -> Block:
	var genesis_transaction = Transaction.new("System", "Genesis", 0)
	return Block.new(0, [genesis_transaction], "0")

func get_latest_block() -> Block:
	return chain[-1]

func add_block(new_block: Block):
	new_block.previous_hash = get_latest_block().block_hash
	new_block.block_hash = new_block.calculate_hash()
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
	var chain_data = []
	for block in chain:
		chain_data.append(block.to_dict())
	file.store_string(JSON.stringify(chain_data, "\t"))
	file.close()

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
		var block = Block.new(block_dict["index"], block_dict["transactions"], block_dict["previous_hash"])
		block.from_dict(block_dict)
		chain.append(block)
	file.close()
	print("Blockchain loaded successfully.")

func get_total_dbs() -> int:
	var total_dbs = 0
	for block in chain:
		for transaction in block.transactions:
			total_dbs += transaction.amount
	return total_dbs
