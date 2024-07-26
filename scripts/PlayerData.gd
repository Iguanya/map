# scripts/PlayerData.gd

extends Node

# Dictionary to hold player data
var player_data = {
    "player_name": "",
    "character": ""
}

# Function to set player data
func set_player_data(name, character):
    player_data["player_name"] = name
    player_data["character"] = character

# Function to get player data
func get_player_data():
    return player_data
