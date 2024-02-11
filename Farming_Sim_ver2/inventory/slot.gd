extends PanelContainer

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
	
