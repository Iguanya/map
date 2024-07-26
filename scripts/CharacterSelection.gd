# scripts/CharacterSelection.gd

extends Control

func _ready():
    $Character1Button.connect("pressed", self, "_on_Character1Button_pressed")
    $Character2Button.connect("pressed", self, "_on_Character2Button_pressed")

func _on_Character1Button_pressed():
    PlayerData.set_player_data("Player1", "Character 1")
    print("Character 1 selected")
    proceed_to_game()

func _on_Character2Button_pressed():
    PlayerData.set_player_data("Player1", "Character 2")
    print("Character 2 selected")
    proceed_to_game()

func proceed_to_game():
    print("Proceeding to game with selected character: %s" % PlayerData.get_player_data()["character"])
    # GetTree().change_scene("res://scenes/MainGame.tscn")
