# cardManager.gd
extends Node

var maisha_hutokea = []

func _ready():
	_load_maisha_hutokea_data()

func _load_maisha_hutokea_data():
	var file = FileAccess.open("res://maishahutokea/maisha_hutokea.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		
		if parse_result == OK:
			maisha_hutokea = json.get_data()
			print("Loaded Maisha Hutokea data: ", maisha_hutokea)
		else:
			print("Failed to parse JSON with error code: ", parse_result)
	else:
		print("Failed to load Maisha Hutokea data. File could not be opened.")

func get_random_card():
	if maisha_hutokea.size() == 0:
		return null
	var rand_index = randi() % maisha_hutokea.size()
	return maisha_hutokea[rand_index]

func assign_random_card_to_player(player):
	var card = get_random_card()
	if card:
		player.assign_card(card)
		# Optionally remove the card to prevent duplicates
		# maisha_hutokea.remove(rand_index)
