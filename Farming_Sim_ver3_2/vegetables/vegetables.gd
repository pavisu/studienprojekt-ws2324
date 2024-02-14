extends Node3D

@export var harvest_amount = 1
@export var harvest_amount_seed = 2
@export var croptype = CropType.CARROT

# Reference to PickUp and SlotData
const PickUp = preload("res://item/pick_up/pick_up.tscn")

# Data about vegetable item
const carrot = preload("res://item/items/carrot.tres")
const carrot_seed = preload("res://item/items/carrot_seed.tres")
const lettuce = preload("res://item/items/lettuce.tres")
const lettuce_seed = preload("res://item/items/lettuce_seed.tres")

# Objects and Collision Shape of the vegetables
@onready var carrot_full = get_node("02_carrot_full")
@onready var carrot_full_col = get_node("02_carrot_full/StaticBody3D/CollisionShape3D")
@onready var carrot_middle = get_node("02_carrot_middle")
@onready var carrot_middle_col = get_node("02_carrot_middle/StaticBody3D/CollisionShape3D")
@onready var carrot_seedling = get_node("02_carrot_seed")
@onready var carrot_seedling_col = get_node("02_carrot_seed/StaticBody3D/CollisionShape3D")
@onready var lettuce_full = get_node("01_lettuce_full")
@onready var lettuce_full_col = get_node("01_lettuce_full/StaticBody3D/CollisionShape3D")
@onready var lettuce_middle = get_node("01_lettuce_middle")
@onready var lettuce_middle_col = get_node("01_lettuce_middle/StaticBody3D/CollisionShape3D")
@onready var lettuce_seedling = get_node("01_lettuce_seed")
@onready var lettuce_seedling_col = get_node("01_lettuce_seed/StaticBody3D/CollisionShape3D")

# value for debugging output in console
var debug = false

var harvestable = false

# Value of current growth
var growth_val = 0.0

var growth_time_in_seconds = 2.0

# Seed values for growth stages
var growth_seed_to_middle_val = 2.5
var growth_max_val = 5.0

func get_croptype():
	return croptype

func get_harvest_amount():
	return harvest_amount

func get_harvest_amount_seed():
	return harvest_amount_seed

func isVegetable():
	return true

func create_seed_pick(croptype: String):
	# Create Slot_Data instance
	var slot_data = SlotData.new()
	# Create PickUp instance
	var pick_up = PickUp.instantiate()
	
	# set the type of crop
	if croptype == CropType.CARROT:
		slot_data.item_data = carrot_seed
	if croptype == CropType.LETTUCE:
		slot_data.item_data = lettuce_seed
		
	# Set the returnable amount of harvested crops
	slot_data.set_quantity(get_harvest_amount_seed())
	pick_up.slot_data = slot_data
	
	# Set the position to be dropped where the crop is harvested
	pick_up.position = global_position
	pick_up.position.y = pick_up.position.y + 1
	return pick_up

func create_crop_pick(croptype: String):
	# Create Slot_Data instance
	var slot_data = SlotData.new()
	# Create PickUp instance
	var pick_up = PickUp.instantiate()
	
	# set the type of crop
	if croptype == CropType.CARROT:
		slot_data.item_data = carrot
	if croptype == CropType.LETTUCE:
		slot_data.item_data = lettuce
		
	# Set the returnable amount of harvested crops
	slot_data.set_quantity(get_harvest_amount())
	pick_up.slot_data = slot_data
	
	# Set the position to be dropped where the crop is harvested
	pick_up.position = global_position
	pick_up.position.y = pick_up.position.y + 1
	return pick_up

func harvest():
	if harvestable:
		# destroy the crop
		queue_free()
		# create crop to pickup
		var pick_up_crop = create_crop_pick(croptype)
		var pick_up_seed = create_seed_pick(croptype)
		
		# Add to world
		get_tree().get_root().add_child(pick_up_crop)
		get_tree().get_root().add_child(pick_up_seed)
		return true
	return false

func _ready():
	# Instantiate invisible "lettuce"	
	lettuce_full.visible = false
	lettuce_full_col.disabled = true
	lettuce_middle.visible = false
	lettuce_middle_col.disabled = true
	lettuce_seedling.visible = false
	lettuce_seedling_col.disabled = true
	
	# Instantiate invisible "carrot"	
	carrot_full.visible = false
	carrot_full_col.disabled = true
	carrot_middle.visible = false
	carrot_middle_col.disabled = true
	carrot_seedling.visible = false
	carrot_seedling_col.disabled = true

func _process(delta):
	if growth_val < growth_max_val:
		growth_val += delta / growth_time_in_seconds
		
	if croptype == CropType.LETTUCE:
		# Visibility of the crop from seedling -> full_grown
		lettuce_full.visible = growth_val >= growth_max_val
		lettuce_middle.visible = growth_val < growth_max_val && growth_val >= growth_seed_to_middle_val
		lettuce_seedling.visible = growth_val < growth_seed_to_middle_val || 0.0
		
		# Activate collision shape of the cropes according to the growing state of the vegtable
		lettuce_full_col.disabled = growth_val < growth_max_val
		lettuce_middle_col.disabled = growth_val >= growth_max_val || growth_val < growth_seed_to_middle_val
		lettuce_seedling_col.disabled = growth_val >= growth_seed_to_middle_val
		
	if croptype == CropType.CARROT:
		# Visibility of the crop from seedling -> full_grown
		carrot_full.visible = growth_val >= growth_max_val
		carrot_middle.visible = growth_val < growth_max_val && growth_val >= growth_seed_to_middle_val
		carrot_seedling.visible = growth_val < growth_seed_to_middle_val || 0.0
		
		# Activate collision shape of the cropes according to the growing state of the vegtable
		carrot_full_col.disabled = growth_val < growth_max_val
		carrot_middle_col.disabled = growth_val >= growth_max_val || growth_val < growth_seed_to_middle_val
		carrot_seedling_col.disabled = growth_val >= growth_seed_to_middle_val	
		
	# Set harverstable if full grown
	harvestable = growth_val >= growth_max_val
		
		
	if debug:
		print("Current growth_val: ", growth_val)
		print("Crop is harvestable: ", harvestable)
	
