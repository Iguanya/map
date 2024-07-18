extends Resource

class_name Block

var index: int
var timestamp: int
var transactions: Array
var previous_hash: String
var block_hash: String  # Renamed to avoid shadowing built-in function

func _init(_index, _transactions, _previous_hash):
	index = _index
	timestamp = Utils.get_unix_time()  # Use the custom Unix time function
	transactions = _transactions
	previous_hash = _previous_hash
	block_hash = calculate_hash()  # Updated to use the new variable name

func calculate_hash() -> String:
	var data = str(index) + str(timestamp) + str(transactions) + previous_hash
	return hash_string(data)

func hash_string(data: String) -> String:
	var sha256 = HashingContext.new()
	sha256.start(HashingContext.HASH_SHA256)
	sha256.update(data.to_utf8_buffer())
	return sha256.finish().hex_encode()
