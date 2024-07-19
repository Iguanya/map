extends Resource

class_name Transaction

var sender: String
var recipient: String
var amount: int

func _init(_sender: String = "", _recipient: String = "", _amount: int = 0):
	sender = _sender
	recipient = _recipient
	amount = _amount

func to_dict() -> Dictionary:
	return {
		"sender": sender,
		"recipient": recipient,
		"amount": amount
	}

func from_dict(dict: Dictionary):
	sender = dict.sender
	recipient = dict.recipient
	amount = dict.amount
	return self
