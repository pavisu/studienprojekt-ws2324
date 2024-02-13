extends CharacterBody3D

@export var inventory_data: InventoryData

@onready var armature = $Armature
@onready var spring_arm_pivot = $SpringArmPivot
@onready var spring_arm = $SpringArmPivot/SpringArm3D
@onready var anim_tree =$AnimationTree
@onready var ray = $SpringArmPivot/RayCast3D

const SPEED = 5.0
const LERP_VAL = .15
const JUMP_VAL= 5.0
const RAY_DISTANCE = 4

signal toggle_inventory()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
		velocity.y -= gravity * delta

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
		print("interact with ", ray.get_collider())
		ray.get_collider().player_interact()
