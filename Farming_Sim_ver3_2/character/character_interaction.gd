extends RayCast3D

# value for debugging output in console
var debug = true

# Reference to character
@onready var character: CharacterBody3D = get_node("../..")

# Reference to vegetables
var plantable_crop = preload("res://vegetables/vegetables.tscn")

# Plant a crop
signal trigger_planting()

# variable to get information about visibility of inventory interface
var inventory_is_visible = false

func transform_coords(coords : Vector3):
	# Rounds the coords to be able to plant on the gridmap
	coords.x = snapped(coords.x, 1)
	coords.y = snapped(coords.y, 1)
	coords.z = snapped(coords.z, 1)
	return coords

# Function to plant at the selected tile
func plant(coords : Vector3, chosen_seed : String):
	var new_crop = plantable_crop.instantiate()
	# Set new crop type
	new_crop.croptype = chosen_seed
	# Round the coordinates for gridmap
	var crop_coords = transform_coords(coords)
	# Add plant to the world
	get_tree().get_root().add_child(new_crop)
	# Scale and transform the plant
	new_crop.scale = Vector3(0.5, 0.5, 0.5)
	new_crop.global_transform.origin = crop_coords
	
	if debug:
		print("Collision Point: ", coords)
		print("Collision Point rounded: ", crop_coords)
		print("CropType: ", new_crop.croptype)
		print("Planting crop")

# Function to harvest the selected plant
func harvest(obj : Object):
	# Get the parent to access harvest method
	var parent = obj.get_parent().get_parent()
	# Check if the object can be harvested
	if parent.has_method("harvest"):
		var isPlanted = parent.harvest()
		if debug:
			print("Plant harvested: ", isPlanted)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create connection for signal
	# needed for status of the inventory toggle
	pass

func trigger_plant(chosen_seed : String) -> bool:
	# Check if inventory is visible
	print("Trigger")
	# Check if raycast is colliding with layer defined in collision mask
	if is_colliding():
		var collision_obj = get_collider()
		var isVegetable = collision_obj.get_parent().get_parent().has_method("isVegetable")
		if isVegetable:
			print("Cant' plant crop")
			return false
			
		else:
			# Plant crop
			var col_point = get_collision_point()
			plant(col_point, chosen_seed)
			return true
		
	# Return if not colliding
	return false

	
# Called every frame. 'delta' is the elapsed time since the previous frame.	
func _process(delta):
	# Check if inventory is visible
	if !inventory_is_visible:
		if Input.is_action_just_pressed("action"):
			# Check if raycast is colliding with layer defined in collision mask
			if is_colliding():
				var collision_obj = get_collider()
				var col_point = get_collision_point()
				var isVegetable = collision_obj.get_parent().get_parent().has_method("isVegetable")
				#var col_layer = collision_obj.
				if debug:
					print("Collision Object: ", collision_obj)
					print("Collision Point: ", col_point)
					print("isVegetable: ", isVegetable)
			
				harvest(collision_obj)
				
		if Input.is_action_just_pressed("action_secondary"):
			trigger_planting.emit()
			print("right-clicked")
		


func set_inventory_visible(isVisible: bool):
	inventory_is_visible = isVisible
	print(inventory_is_visible)
