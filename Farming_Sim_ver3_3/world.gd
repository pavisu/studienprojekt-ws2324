extends Node3D

const PickUp = preload("res://item/pick_up/pick_up.tscn") 

@onready var character: CharacterBody3D = $character
@onready var inventory_interface: Control = $UI/InventoryInterface
@onready var hot_bar_inventory: PanelContainer = $UI/HotBarInventory

func _ready() -> void:
	character.toggle_inventory.connect(toggle_inventory_intrface)
	
	inventory_interface.set_player_inventory_data(character.inventory_data)
	
	inventory_interface.force_close.connect(toggle_inventory_intrface)
	
	hot_bar_inventory.set_inventory_data(character.inventory_data)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_intrface)
		
	character.updated_inventory.connect(update_inventory_ref)


#switch with tab to visible and not visible of inventory
func toggle_inventory_intrface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	# Status of the inventory in character
	character.set_inventory_visible(inventory_interface.visible)
	
	#enable to see the mouse or hotbar
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		hot_bar_inventory.hide()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		hot_bar_inventory.show()
	
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()


func _on_inventory_interface_drop_slot_data(slot_data):
	var pick_up = PickUp.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = character.get_drop_position()
	add_child(pick_up)
	
func update_inventory_ref():
	inventory_interface.set_player_inventory_data(character.inventory_data)
	hot_bar_inventory.set_inventory_data(character.inventory_data)
