extends Control

var coin_value = 0
@onready var coins_value = %CoinsValue

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_grantcoin_pressed():
	coin_value +=10
	print(coin_value)
	coins_value.text = str(coin_value)
