extends PanelContainer

signal slot_clicked(index:int, button:int)

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel


func set_slot_data(slot_data: SlotData) -> void:
	#get reference
	var item_data =slot_data.item_data
	#update texture
	texture_rect.texture= item_data.texture
	#set tooltip text
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	#show or hide quantity label
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
	


func _on_gui_input(event):
	#check if right or left click and if it is pressed
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
