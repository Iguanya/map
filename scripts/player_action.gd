extends Node

var player_name = ""
var funds = 1000  # Example starting funds
var is_turn = false

func _ready():
    connect("new_turn", self, "_on_new_turn")

func _on_new_turn(player):
    if player == self:
        is_turn = true
        show_action_menu()
    else:
        is_turn = false

func show_action_menu():
    # Display UI elements to let the player perform actions
    # Example: pay bills, manage expenses, etc.
    pass

func perform_action(action):
    if is_turn:
        match action:
            "pay_bills":
                pay_bills()
            "manage_expenses":
                manage_expenses()
        # Notify other players about the action taken
        Rpc("notify_action", player_name, action)
        end_turn()

func pay_bills():
    # Logic for paying bills
    funds -= 100

func manage_expenses():
    # Logic for managing expenses
    funds -= 50

remote func notify_action(player, action):
    # Update the UI to show other players the action taken
    pass

func end_turn():
    is_turn = false
    # Notify the Turn Manager that the turn has ended
    emit_signal("end_turn")
