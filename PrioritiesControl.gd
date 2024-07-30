extends Control

# Reference to the PriorityManager
var priority_manager = null
var player_id
var Priority

@onready var priority_list = $VBoxContainer/Priorities

# Called when the node enters the scene tree for the first time.
func _ready():
	priority_manager = get_node("/root/PrioritiesControl")  # Adjust the path as necessary
	update_priority_display()

# Update the UI to show the priorities for the given player
func update_priority_display():
	clear_children(priority_list)  # Clear existing priorities
	var priorities = priority_manager.get_player_priorities(player_id)
	
	for priority in priorities:
		var hbox = HBoxContainer.new()
		
		var name_label = Label.new()
		name_label.text = priority.name
		hbox.add_child(name_label)
		
		var cost_label = Label.new()
		cost_label.text = str(priority.cost) + " DBS"
		hbox.add_child(cost_label)
		
		var checkbox = CheckBox.new()
		checkbox.pressed = priority.is_compulsory
		hbox.add_child(checkbox)
		
		priority_list.add_child(hbox)

# Set the player ID and refresh the display
func set_player_id(id):
	player_id = id
	update_priority_display()

# Called when the player confirms their priority settings
func on_confirm_button_pressed():
	var priorities = []
	for hbox in priority_list.get_children():
		var name = hbox.get_child(0).text
		var cost = int(hbox.get_child(1).text.split(" ")[0])
		var is_compulsory = hbox.get_child(2).pressed
		
		var priority = Priority.new()
		priority.name = name
		priority.cost = cost
		priority.is_compulsory = is_compulsory
		
		priorities.append(priority)
	
	priority_manager.set_player_priorities(player_id, priorities)
	hide()  # Hide the UI after setting priorities

# Utility function to clear all children from a node
func clear_children(node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
