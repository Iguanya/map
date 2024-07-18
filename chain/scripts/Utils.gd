extends Node

class_name Utils

static func get_unix_time() -> int:
	var unix_time: float = Time.get_unix_time_from_system()
	return int(unix_time)
