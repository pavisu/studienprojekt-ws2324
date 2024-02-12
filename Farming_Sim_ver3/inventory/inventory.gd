extends PanelContainer

const Slot = preload("res://inventory/slot.tscn")

@onready var item_grid: GridContainer = $MarginContainer/ItemGrid

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)

#inventory updates
func populate_item_grid(inventory_data: InventoryData) -> void:
	#clear the item grid of any children
	for child in item_grid.get_children():
		child.queue_free()
	
	#slot for every slotdata -> child to the itemgrid
	for slot_data in inventory_data.slot_datas:
		var slot = Slot.instantiate()
		item_grid.add_child(slot)
		
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		# check slot data and update parameter
		if slot_data:
			slot.set_slot_data(slot_data)
		
