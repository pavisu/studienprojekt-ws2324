extends PanelContainer

#use hotbar
signal hot_bar_use(index: int)

const Slot = preload("res://inventory/slot.tscn")

@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_pressed():
		return 
		
	#return index, emitting 0 through 5
	if range(KEY_1, KEY_7).has(event.keycode):
		hot_bar_use.emit(event.keycode - KEY_1)


# set up connection to the inventory_data
func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_hot_bar)
	populate_hot_bar(inventory_data)
	hot_bar_use.connect(inventory_data.use_slot_data)

#hotbar update
func populate_hot_bar(inventory_data: InventoryData) -> void:
	#clear the item grid of any children
	for child in h_box_container.get_children():
		child.queue_free()
	
	# pass only 6 elements
	for slot_data in inventory_data.slot_datas.slice(0,6):
		var slot = Slot.instantiate()
		h_box_container.add_child(slot)
		
		# check slot data and update parameter
		if slot_data:
			slot.set_slot_data(slot_data)
		
