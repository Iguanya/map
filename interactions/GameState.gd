extends Node

var state := {
	"health": 100,
	"key": 0
}

func get_value(key):
	if state.has(key):
		return state[key]
		
	printerr("key not present in state: ", key)
	
	
func set_value(key, value):
	state[key] = value
