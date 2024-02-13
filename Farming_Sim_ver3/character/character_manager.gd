extends Node

var character

func use_slot_data(slot_data: SlotData) -> void:
	#pass character as an argument
	slot_data.item_data.use(character)
