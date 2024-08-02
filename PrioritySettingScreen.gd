extends Control

signal priority_selected(player_id, selected_priorities)

var priorities = [
	{"name": "Rent for Home", "compulsory": true},
	{"name": "Rent for Business", "compulsory": true},
	{"name": "Medical Check", "compulsory": false},
	{"name": "Phone Credit", "compulsory": true},
	{"name": "Clean Water", "compulsory": false},
	{"name": "Electricity", "compulsory": false},
	{"name": "Fresh Meat", "compulsory": false},
	{"name": "Fares/Travel", "compulsory": false},
	{"name": "Cooking Gas", "compulsory": false},
	{"name": "Faith Contribution", "compulsory": false},
	{"name": "Maintenance", "compulsory": false},
	{"name": "Parents & Family", "compulsory": false},
	{"name": "Fresh Fruit & Vegetables", "compulsory": false}    
]

var selected_priorities = []
var max_selection = 3

func _ready():
	randomize_priorities()
	display_priorities()

func randomize_priorities():
	selected_priorities.clear()
	
	var compulsory_priorities = []
	var non_compulsory_priorities = []
	
	for priority in priorities:
		if priority["compulsory"]:
			compulsory_priorities.append(priority)
		else:
			non_compulsory_priorities.append(priority)
	
	compulsory_priorities.shuffle()
	non_compulsory_priorities.shuffle()
	
	var compulsory_count = randi() % 3 + 1
	
	for i in range(compulsory_count):
		if i < compulsory_priorities.size():
			selected_priorities.append(compulsory_priorities[i])
	
	var remaining_count = 5 - selected_priorities.size()
	for i in range(remaining_count):
		if i < non_compulsory_priorities.size():
			selected_priorities.append(non_compulsory_priorities[i])
	
	selected_priorities.shuffle()

func display_priorities():
	for i in range(15):
		var button_path = "PriorityContainer/PriorityButton" + str(i + 1)
		var button = get_node(button_path) as Button
		if button:
			button.hide()
	
	for i in range(5):
		var button_path = "PriorityContainer/PriorityButton" + str(i + 1)
		var button = get_node(button_path) as Button
		if button:
			button.text = selected_priorities[i]["name"]
			button.disabled = selected_priorities[i]["compulsory"]
			button.show()

func _on_PriorityButton_pressed(button):
	if selected_priorities.size() < max_selection or button.disabled:
		button.add_color_override("font_color", Color(1, 0, 0))
		button.disabled = true

func _on_ConfirmButton_pressed():
	var chosen_priorities = []
	for i in range(5):
		var button_path = "PriorityContainer/PriorityButton" + str(i + 1)
		var button = get_node(button_path) as Button
		if button and button.disabled:
			chosen_priorities.append(button.text)
	
	if chosen_priorities.size() >= max_selection:
		emit_signal("priority_selected", get_tree().get_network_unique_id(), chosen_priorities)
		queue_free()










