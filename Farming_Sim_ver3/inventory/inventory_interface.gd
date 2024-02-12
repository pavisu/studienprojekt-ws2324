extends Control

#variable to store slot_data
var grabbed_slot_data: SlotData

@onready var player_inventory: PanelContainer = $PlayerInventory
@onready var grabbed_slot: PanelContainer = $GrabbedSlot

func _physics_process(delta:float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5,5)

func set_player_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventory_data)
	
func on_inventory_interact(inventory_data: InventoryData,
		index:int, button:int) -> void:
	# check if interact with slots
	#print("%s %s %s" % [inventory_data, index, button])
	
	#no slot_data grabbed
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		# _ can be anything, if we do have something in the slot_data
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
			
		#case for using the item
		[null, MOUSE_BUTTON_RIGHT]:
			pass
		# _ can be anything, if we do have something in the slot_data
		# single drop of item with right click
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
			
	#print(grabbed_slot_data)
	update_grabbed_slot()
	
	#update display
func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()
			
	
