extends Node

var character

func use_slot_data(slot_data: SlotData) -> void:
	#pass character as an argument
	slot_data.item_data.use(character)
	
func get_global_position() -> Vector3:
	return character.global_position
