# MaishaHutokea.gd
extends Control

@onready var card_description_label = $Panel/RichTextLabel  # Adjust the path accordingly
@onready var rich_text_label = $Panel/RichTextLabel

signal card_assigned(card)

func _ready():
	print("MaishaHutokea ready.")
	connect("card_assigned", Callable(self, "_on_card_assigned"))

func update_card(card):
	if card_description_label:
		card_description_label.clear()
		card_description_label.text = card["description"]
		card_description_label.scroll_to_line(0)  # Ensure the text starts from the top
		print("Updated RichTextLabel with card description: ", card["description"])
	else:
		print("RichTextLabel not found!")

func _on_card_assigned(card):
	print("Card assigned: ", card)
	update_card(card)
