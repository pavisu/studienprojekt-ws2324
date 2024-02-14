extends Resource
class_name InventoryData

signal inventory_updated(inventory_data: InventoryData)
signal inventory_interact(inventory_data: InventoryData,index:int, button:int)

@export var slot_datas: Array[SlotData]

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	#check if grabbed
	if slot_data:
		slot_datas[index] = null
		#update inventory if grabbed
		inventory_updated.emit(self)
		return slot_data
	else:
		return null
		
func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	var return_slot_data: SlotData
	
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[index] = grabbed_slot_data
		return_slot_data = slot_data
		
	inventory_updated.emit(self)
	return return_slot_data
	
	#slot_datas[index] = grabbed_slot_data
	#inventory_updated.emit(self)
	#swapping if something has an item_data in the slot
	#return slot_data

	
#to drop single item into slot
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
		
	
	inventory_updated.emit(self)
	
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

#consume consumable item_data with right click
func use_slot_data(index: int) -> void:
	var slot_data = slot_datas[index]
	
	if not slot_data:
		return
		
	# decrease slot item 
	slot_data.quantity -= 1
	if slot_data.quantity < 1:
		slot_datas[index] = null
		
	#if slot_data.item_data is ItemDataConsumable:
	#	slot_data.quantity -= 1
	#	if slot_data.quantity < 1:
	#		slot_datas[index] = null
	
	print(slot_data.item_data.name)
	CharacterManager.use_slot_data(slot_data)
	
	inventory_updated.emit(self)
	
	

#pick up the pick_up item into slot_data (walk to the item	
func pick_up_slot_data(slot_data: SlotData) -> bool:
	
	# search mergable slot and take that instead
	for index in slot_datas.size():
		if slot_datas[index] and slot_datas[index].can_fully_merge_with(slot_data):
			slot_datas[index].fully_merge_with(slot_data)
			inventory_updated.emit(self)
			return true
	
	for index in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
			inventory_updated.emit(self)
			return true
	
	return false
	
#click on inventorysystem get signal
func on_slot_clicked(index:int, button:int) -> void:
	#print("inventory interact")
	inventory_interact.emit(self, index, button)
