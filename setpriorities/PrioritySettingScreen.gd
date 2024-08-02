extends Control

signal priority_selected(player_id, priorities)

var selected_priorities = []
var current_index = 0
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

func _ready():
	randomize_priorities()
	display_priorities()
	set_process_input(true)

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
			if i == current_index:
				button.add_theme_color_override("font_color", Color.RED)

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_UP:
				navigate_up()
			elif event.keycode == KEY_DOWN:
				navigate_down()
			elif event.keycode == KEY_SPACE:
				toggle_selection()
			elif event.keycode == KEY_ENTER:
				confirm_selection()

func navigate_up():
	current_index -= 1
	if current_index < 0:
		current_index = 4
	update_button_highlight()

func navigate_down():
	current_index += 1
	if current_index > 4:
		current_index = 0
	update_button_highlight()

func toggle_selection():
	var button_path = "PriorityContainer/PriorityButton" + str(current_index + 1)
	var button = get_node(button_path) as Button
	if button and not selected_priorities[current_index]["compulsory"]:
		if button.has_theme_color_override("font_color"):
			button.remove_theme_color_override("font_color")
			selected_priorities[current_index]["selected"] = false
		else:
			button.add_theme_color_override("font_color", Color.RED)
			selected_priorities[current_index]["selected"] = true

func update_button_highlight():
	for i in range(5):
		var button_path = "PriorityContainer/PriorityButton" + str(i + 1)
		var button = get_node(button_path) as Button
		if button:
			if i == current_index:
				button.add_theme_color_override("font_color", Color.RED)
			else:
				button.remove_theme_color_override("font_color")

func confirm_selection():
	var selected = []
	for i in range(5):
		if selected_priorities[i]["compulsory"] or selected_priorities[i].get("selected", false):
			selected.append(selected_priorities[i])
	if selected.size() <= 3:
		emit_signal("priority_selected", multiplayer.get_unique_id(), selected)
		queue_free()
	else:
		print("Select up to 3 priorities only.")
