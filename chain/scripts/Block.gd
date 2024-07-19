extends Resource

class_name Block

var index: int
var timestamp: int
var transactions: Array
var previous_hash: String
var block_hash: String
var nonce: int = 0

func _init(_index, _transactions, _previous_hash):
	index = _index
	timestamp = Utils.get_unix_time()
	transactions = _transactions
	previous_hash = _previous_hash
	block_hash = calculate_hash()

func calculate_hash() -> String:
	var data = str(index) + str(timestamp) + str(transactions) + previous_hash + str(nonce)
	return hash_string(data)

func hash_string(data: String) -> String:
	var sha256 = HashingContext.new()
	sha256.start(HashingContext.HASH_SHA256)
	sha256.update(data.to_utf8_buffer())
	return sha256.finish().hex_encode()

func mine_block(difficulty: int):
	var target = "0".repeat(difficulty)
	while block_hash.substr(0, difficulty) != target:
		nonce += 1
		block_hash = calculate_hash()

func to_dict() -> Dictionary:
	var transactions_dict = []
	for transaction in transactions:
		transactions_dict.append(transaction.to_dict())
	return {
		"index": index,
		"timestamp": timestamp,
		"transactions": transactions_dict,
		"previous_hash": previous_hash,
		"block_hash": block_hash,
		"nonce": nonce
	}

func from_dict(dict: Dictionary):
	index = dict["index"]
	timestamp = dict["timestamp"]
	transactions = []
	for transaction_dict in dict["transactions"]:
		var transaction = Transaction.new()
		transaction.from_dict(transaction_dict)
		transactions.append(transaction)
	previous_hash = dict["previous_hash"]
	block_hash = dict["block_hash"]
	nonce = dict["nonce"]
	return self
