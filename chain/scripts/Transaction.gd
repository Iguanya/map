extends Resource

class_name Transaction

var sender: String
var recipient: String
var amount: int

func _init(_sender, _recipient, _amount):
	sender = _sender
	recipient = _recipient
	amount = _amount
