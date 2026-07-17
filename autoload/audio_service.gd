extends Node

var master_volume_db := 0.0

func set_master_volume(value_db: float) -> void:
	master_volume_db = value_db
	AudioServer.set_bus_volume_db(0, master_volume_db)
