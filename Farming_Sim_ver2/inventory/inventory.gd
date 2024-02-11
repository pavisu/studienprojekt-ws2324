extends PanelContainer

const Slot = preload("res://inventory/slot.tscn")

@onready var item_grid: GridContainer = $MarginContainer/ItemGrid

func set_inventory_data(inventory_data: InventoryData) -> void:
	populate_item_grid(inventory_data.slot_datas)

#inventory updates
func populate_item_grid(slot_datas: Array[SlotData]) -> void:
	#clear the item grid of any children
	for child in item_grid.get_children():
		child.queue_free()
	
	#slot for every slotdata -> child to the itemgrid
	for slot_data in slot_datas:
		var slot = Slot.instantiate()
		item_grid.add_child(slot)
		
		# check slot data and update parameter
		if slot_data:
			slot.set_slot_data(slot_data)
		
