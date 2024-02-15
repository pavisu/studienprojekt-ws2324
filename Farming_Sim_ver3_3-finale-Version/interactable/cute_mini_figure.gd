extends RigidBody3D

#interact with inventory
signal toggle_inventory(external_inventory_owner)

@export var inventory_data: InventoryData

#throw the signal when interact
func player_interact() -> void:
	toggle_inventory.emit(self)
