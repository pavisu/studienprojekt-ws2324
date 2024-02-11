extends Node3D

@onready var chara_05: CharacterBody3D = $chara_05

@onready var inventory_interface: Control = $UI/InventoryInterface

func _ready() -> void:
	chara_05.toggle_inventory.connect(toggle_inventory_intrface)
	
	inventory_interface.set_player_inventory_data(chara_05.inventory_data)

#switch with tab to visible and not visible of inventory
func toggle_inventory_intrface() -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	#enable to see the mouse
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
