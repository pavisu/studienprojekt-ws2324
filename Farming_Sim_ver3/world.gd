extends Node3D

const PickUp = preload("res://item/pick_up/pick_up.tscn")

@onready var character: CharacterBody3D = $character
@onready var inventory_interface: Control = $UI/InventoryInterface

func _ready() -> void:
	character.toggle_inventory.connect(toggle_inventory_intrface)
	
	inventory_interface.set_player_inventory_data(character.inventory_data)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_intrface)
	

#switch with tab to visible and not visible of inventory
func toggle_inventory_intrface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	#enable to see the mouse
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()


func _on_inventory_interface_drop_slot_data(slot_data):
	var pick_up = PickUp.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = character.get_drop_position()
	add_child(pick_up)
