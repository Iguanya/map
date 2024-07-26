extends Node

var event_timer = Timer.new()

func _ready():
    event_timer.set_wait_time(rand_range(10, 60))
    event_timer.connect("timeout", self, "_on_event_timer_timeout")
    add_child(event_timer)
    event_timer.start()

func _on_event_timer_timeout():
    if is_turn:
        trigger_random_event()
        event_timer.start()  # Restart the timer

func trigger_random_event():
    var event = get_random_event()
    apply_event_effects(event)

func get_random_event():
    var events = [
        {"name": "Medical Emergency", "cost": 200},
        {"name": "Business Opportunity", "benefit": 300}
    ]
    return events[randi() % events.size()]

func apply_event_effects(event):
    if event.has("cost"):
        reduce_player_funds(event["cost"])
    elif event.has("benefit"):
        increase_player_funds(event["benefit"])

func reduce_player_funds(amount):
    funds -= amount

func increase_player_funds(amount):
    funds += amount
