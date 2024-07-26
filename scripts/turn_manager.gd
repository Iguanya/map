extends Node

var players = []  # List of players
var current_turn = 0
var turn_timer = Timer.new()

func _ready():
    turn_timer.set_wait_time(30)  # Set time per turn
    turn_timer.connect("timeout", self, "_on_turn_timer_timeout")
    add_child(turn_timer)
    start_game()

func start_game():
    current_turn = 0
    turn_timer.start()
    start_turn()

func start_turn():
    var current_player = players[current_turn]
    emit_signal("new_turn", current_player)
    turn_timer.start()

func end_turn():
    turn_timer.stop()
    current_turn += 1
    if current_turn >= players.size():
        current_turn = 0
    start_turn()

func _on_turn_timer_timeout():
    end_turn()

signal new_turn(player)
