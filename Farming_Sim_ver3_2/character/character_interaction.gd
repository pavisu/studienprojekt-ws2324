extends RayCast3D

# value for debugging output in console
var debug = true

@onready var character: CharacterBody3D = get_node("../..")
# Reference to vegetables
var plantable_crop = preload("res://vegetables/vegetables.tscn")

# variable to get information about visibility of inventory interface
var inventory_is_visible = false

func transform_coords(coords : Vector3):
	# Rounds the coords to be able to plant on the gridmap
	coords.x = snapped(coords.x, 1)
	coords.y = snapped(coords.y, 1)
	coords.z = snapped(coords.z, 1)
	return coords

# Function to plant at the selected tile
func plant(coords : Vector3):
	var new_crop = plantable_crop.instantiate()
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
	character.inventory_is_visible.connect(_on_Character_inventory_is_visible)

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
			# Check if raycast is colliding with layer defined in collision mask
			if is_colliding():
				var collision_obj = get_collider()
				var isVegetable = collision_obj.get_parent().get_parent().has_method("isVegetable")
				if isVegetable:
					print("Cant' plant crop")
					return
				
				else:
					# Plant crop
					var col_point = get_collision_point()
					plant(col_point)

# Handles the thrown signal from character
func _on_Character_inventory_is_visible(isVisible : bool):
	# Update information of visibility of character inventory
	inventory_is_visible = isVisible
	if debug:
		print(inventory_is_visible)
