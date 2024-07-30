extends Node

var available_priorities = []
var player_priorities = {}
var Priority

func _ready():
	load_priorities()
	randomize_player_priorities()

func load_priorities():
	available_priorities.append(Priority.new("Rent for Home", 3000, false))
	available_priorities.append(Priority.new("Medical Check", 4500, false))
	available_priorities.append(Priority.new("Phone Credit", 600, false))
	available_priorities.append(Priority.new("Clean Water", 800, false))
	available_priorities.append(Priority.new("Rent for Business", 5000, false))
	# Add more priorities as needed

func randomize_player_priorities():
	var random = RandomNumberGenerator.new()
	random.randomize()

	for player_id in get_player_ids():
		var compulsory_count = random.randi_range(1, 3)  # Randomize 1-3 compulsory needs
		var player_priority_list = []

		# Randomly pick compulsory priorities
		for i in range(compulsory_count):
			var priority = available_priorities[random.randi_range(0, available_priorities.size() - 1)]
			priority.is_compulsory = true
			player_priority_list.append(priority)

		# Randomly pick non-compulsory priorities
		for i in range(3):  # Assume each player has 3 priorities in total
			var priority = available_priorities[random.randi_range(0, available_priorities.size() - 1)]
			if priority not in player_priority_list:
				player_priority_list.append(priority)

		player_priorities[player_id] = player_priority_list

func get_player_ids():
	# Return the list of player IDs in your game
	return ["player1", "player2", "player3", "player4"]  # Example player IDs

func get_player_priorities(player_id):
	return player_priorities.get(player_id, [])

func set_player_priorities(player_id, priorities):
	player_priorities[player_id] = priorities
