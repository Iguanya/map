extends Resource

class_name Block

var index: int
var timestamp: int
var transactions: Array
var previous_hash: String
var block_hash: String  # Renamed to avoid shadowing built-in function
var nonce: int = 0  # Declare the nonce variable
var proceedings: RichTextLabel

func _init(_index, _transactions, _previous_hash, _proceedings):
	index = _index
	timestamp = Utils.get_unix_time()  # Use Utils.get_unix_time() for Unix timestamp
	transactions = _transactions
	previous_hash = _previous_hash
	block_hash = calculate_hash()  # Updated to use the new variable name

func calculate_hash() -> String:
	var data = str(index) + str(timestamp) + str(transactions) + previous_hash + str(nonce)
	return hash_string(data)

func hash_string(data: String) -> String:
	var sha256 = HashingContext.new()
	sha256.start(HashingContext.HASH_SHA256)
	sha256.update(data.to_utf8_buffer())
	return sha256.finish().hex_encode()

func mine_block(difficulty: int):
	var start_time = Utils.get_unix_time()
	var target = "0".repeat(difficulty)
	var hash_count = 0
	if proceedings:
		proceedings.append_text("Mining started. Target: Ends with " + target + "\n")
	while not block_hash.ends_with(target):
		nonce += 1
		block_hash = calculate_hash()
		hash_count += 1
		if hash_count % 1000 == 0 and proceedings:  # Log every 1000 hashes
			proceedings.append_text("Hashes computed: " + str(hash_count) + " Current hash: " + block_hash + "\n")
	var end_time = Utils.get_unix_time()
	if proceedings:
		proceedings.append_text("Block mined in " + str(end_time - start_time) + " seconds\n")
		proceedings.append_text("Total hashes computed: " + str(hash_count) + "\n")
