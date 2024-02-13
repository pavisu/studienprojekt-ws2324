extends Node3D

@export var harvest_amount = 1
@export var crop = "carrot"

@onready var lettuce_full = get_node("01_lettuce_full")
@onready var lettuce_full_col = get_node("01_lettuce_full/StaticBody3D/CollisionShape3D")
@onready var lettuce_middle = get_node("01_lettuce_middle")
@onready var lettuce_middle_col = get_node("01_lettuce_middle/StaticBody3D/CollisionShape3D")
@onready var lettuce_seedling = get_node("01_lettuce_seed")
@onready var lettuce_seedling_col = get_node("01_lettuce_seed/StaticBody3D/CollisionShape3D")
@onready var carrot_full = get_node("02_carrot_full")
@onready var carrot_full_col = get_node("02_carrot_full/StaticBody3D/CollisionShape3D")
@onready var carrot_middle = get_node("02_carrot_middle")
@onready var carrot_middle_col = get_node("02_carrot_middle/StaticBody3D/CollisionShape3D")
@onready var carrot_seedling = get_node("02_carrot_seed")
@onready var carrot_seedling_col = get_node("02_carrot_seed/StaticBody3D/CollisionShape3D")

# value for debugging output in console
var debug = false

var harvestable = false

# Value of current growth
var growth_val = 0.0

var growth_time_in_seconds = 2.0

# Seed values for growth stages
var growth_seed_to_middle_val = 2.5
var growth_max_val = 5.0

func get_crop():
	return crop

func get_harvest_amount():
	return harvest_amount

func isVegetable():
	return true

func harvest():
	if harvestable:
		# destroy the crop
		queue_free()
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
		
	if crop == "lettuce":
		# Visibility of the crop from seedling -> full_grown
		lettuce_full.visible = growth_val >= growth_max_val
		lettuce_middle.visible = growth_val < growth_max_val && growth_val >= growth_seed_to_middle_val
		lettuce_seedling.visible = growth_val < growth_seed_to_middle_val || 0.0
		
		# Activate collision shape of the cropes according to the growing state of the vegtable
		lettuce_full_col.disabled = growth_val < growth_max_val
		lettuce_middle_col.disabled = growth_val >= growth_max_val || growth_val < growth_seed_to_middle_val
		lettuce_seedling_col.disabled = growth_val >= growth_seed_to_middle_val
		
	if crop == "carrot":
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
	
