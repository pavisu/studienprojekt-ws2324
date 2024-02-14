extends CharacterBody3D

# value for debugging output in console
var debug = true

@export var inventory_data: InventoryData

@onready var armature = $Armature
@onready var spring_arm_pivot = $SpringArmPivot
@onready var spring_arm = $SpringArmPivot/SpringArm3D
@onready var anim_tree =$AnimationTree
@onready var ray = $SpringArmPivot/RayCast3D
@onready var camera = $SpringArmPivot/SpringArm3D/Camera3D
@onready var skeleton_3d = $Armature/Skeleton3D


const SPEED = 5.0
const LERP_VAL = .15
const JUMP_VAL= 5.0
const RAY_DISTANCE = 4
const MAX_FALL_HEIGHT = -10


signal toggle_inventory()

signal updated_inventory()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var health: int = 5

func _ready():
	CharacterManager.character = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Trigger plants
	ray.trigger_planting.connect(plant_crop)

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(-event.relative.x * .005)
		spring_arm.rotate_x(-event.relative.y * .005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)
		
		# Ray movement with mouse
		ray.rotate_x(-event.relative.y * .005)
		ray.rotation.x = clamp(ray.rotation.x, PI/4, PI/2)
		
		# Character movement with camera
		armature.rotate_y(-event.relative.x * .005)
		
	
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
		
		
	if Input.is_action_just_pressed("interact"):
		interact()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		# check if character is falling beyond the floor
		if global_position.y >= MAX_FALL_HEIGHT:
			velocity.y -= gravity * delta
		else:
			# character falling endless
			# reset character on start position
			global_position = Vector3(0,1,0)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * SPEED, LERP_VAL)
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)
	
	if Input.is_action_pressed("jump"):
			if is_on_floor():
				velocity.y = JUMP_VAL
		
	anim_tree.set("parameters/BlendSpace1D/blend_position",Vector2(velocity.x,velocity.z).length() / SPEED)

	move_and_slide()

func interact() -> void:
	if ray.is_colliding():
		var col_obj = ray.get_collider()
		print("interact with ", col_obj)
		# Check if handler is colliding 
		if col_obj.has_method("player_interact"):
			ray.get_collider().player_interact()
		
#drop location in front of character (using ray position)
func get_drop_position() -> Vector3:
	# buggy drop of the items with raycast
	#var direction = -ray.global_transform.basis.z
	#return ray.global_position + direction
	
	# drops the item behind the player model
	var direction = -skeleton_3d.global_transform.basis.z
	return skeleton_3d.global_position + direction

func heal(heal_value: int) -> void:
	health += heal_value

# Set status of the inventory in character_data
func set_inventory_visible(isVisible : bool):
	# Set the information in character_interaction
	ray.set_inventory_visible(isVisible)
	
# Plant the crop
func plant_crop():
	# get the seed from first slot of the inventory
	var slot = inventory_data.slot_datas[0]
	if slot != null:
		# Select the seed
		var chosen_seed = ""
		if slot.item_data.name == "carrot_seed":
			chosen_seed = "carrot"
		if slot.item_data.name == "lettuce_seed":
			chosen_seed = "lettuce"
	
		if ray.trigger_plant(chosen_seed):
			# decrease slot
			slot.quantity -= 1
			if slot.quantity < 1:
				inventory_data.slot_datas[0] = null
			# Send signal about the new inventory
			updated_inventory.emit()		
			if debug:
				print("Planting Slot Quantity: ", slot.quantity)
				print("Planting suceeded")
		else:
			if debug:
				print("Planting failed")
	else:
		if debug:
			print("Planting failed")
