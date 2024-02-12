extends Resource
class_name InventoryData

signal inventory_interact(inventory_data: InventoryData,index:int, button:int)

@export var slot_datas: Array[SlotData]

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	#check if grabbed
	if slot_data:
		return slot_data
	else:
		return null
	
#click on inventorysystem get signal
func on_slot_clicked(index:int, button:int) -> void:
	#print("inventory interact")
	inventory_interact.emit(self, index, button)
