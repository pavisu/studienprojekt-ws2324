extends Resource
class_name SlotData

const MAX_STACK_SIZE: int = 99

@export var item_data: ItemData
@export_range(1, MAX_STACK_SIZE) var quantity: int = 1: set = set_quantity

#check if it can add one item
func can_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data \
				and item_data.stackable \
				and quantity < MAX_STACK_SIZE

#can merge stackable data: look if exceeded MAX_STACK_SIZE and not merge just swap
func can_fully_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data \
				and item_data.stackable \
				and quantity + other_slot_data.quantity <= MAX_STACK_SIZE

# merge with stackable data
func fully_merge_with(other_slot_data: SlotData) -> void:
	quantity += other_slot_data.quantity
	
#create single slot data to drop
func create_single_slot_data() -> SlotData:
	var new_slot_data = duplicate()
	new_slot_data.quantity = 1
	quantity -= 1
	return new_slot_data

func set_quantity(value: int) -> void:
	quantity = value
	#check quantity if stackable
	if quantity > 1 and not item_data.stackable:
		quantity = 1
		push_error("%s is not stackable,setting quantity to 1" % item_data.name)


