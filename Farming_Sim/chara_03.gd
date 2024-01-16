extends CharacterBody3D


@onready var armature = $Armature
@onready var spring_arm_pivot = $SpringArmPivot
@onready var spring_arm = $SpringArmPivot/SpringArm3D
@onready var anim_tree =$AnimationTree
@onready var ray = $RayCast3D

const SPEED = 5.0
const LERP_VAL = .15
const JUMP_VAL= 5.0
const RAY_DISTANCE = 4


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

func _physics_process(delta):
	# Rotate to Player Character
	var	coll_obj = ray.get_collider()
	var	coll_point = ray.get_collision_point()
	print(coll_obj)
	print(coll_point)
	if coll_obj is GridMap:
		#var cell_hit = coll_obj.local_to_map(to_local(coll_point))
		#var item_id = coll_obj.get_cell_item(to_global(cell_hit))
		var cell_hit = coll_point
		print(cell_hit)
		#if cell_hit.x <= 0:
		#	cell_hit.x = floor(cell_hit.x)
		#else:
		#	cell_hit.x = floor(cell_hit.x)
		#if cell_hit.z <= 0:
		#	cell_hit.z = floor(cell_hit.z)
		#else:
		#	cell_hit.z = floor(cell_hit.z)
		cell_hit.x = floor(cell_hit.x)
		cell_hit.z = floor(cell_hit.z)
		cell_hit.y -= 1
		var item_id = coll_obj.get_cell_item(cell_hit)
		#if item_id == 1:
		if Input.is_action_pressed("action"):
			#coll_obj.set_cell_item(to_global(cell_hit), 0, 0)
			# Check if the cell is the topmost cell
			if coll_obj.get_cell_item(Vector3(cell_hit.x, cell_hit.y+1,cell_hit.z)) == -1:
				coll_obj.set_cell_item(cell_hit.ceil(), 0, 0)
		#print(to_global(cell_hit))
		print(cell_hit)
		print(item_id)
		print("Gridmap hit")
		#print(coll_obj.get_used_cells())
		
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
		# Rotate Ray with character
		#var direction_ray = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var direction_ray = (transform.basis * Vector3((2 * PI), 0, (2 * PI))).normalized()
		direction_ray.x *= RAY_DISTANCE
		direction_ray.z *= RAY_DISTANCE
		#direction_ray = direction_ray.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
		direction_ray = direction_ray.rotated(Vector3.UP, spring_arm_pivot.rotation.y + (2.355))
		
		ray.position.x = direction_ray.x
		ray.position.z = direction_ray.z
		#ray.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)
		# Rotate Ray with character
		var camerapos = get_viewport().get_mouse_position()
		print(spring_arm.rotation)
		#print(camerapos)
		#print(camerapos.position)
		var direction_ray = (transform.basis * Vector3((2 * PI), 0, (2 * PI))).normalized()
		direction_ray.x *= RAY_DISTANCE
		direction_ray.z *= RAY_DISTANCE
		#direction_ray = direction_ray.rotated(Vector3.UP, spring_arm_pivot.rotation.y + (PI/1.3333))
		direction_ray = direction_ray.rotated(Vector3.UP, spring_arm_pivot.rotation.y + (2.355))
	
			
		ray.position.x = direction_ray.x
		ray.position.z = direction_ray.z

	if Input.is_action_pressed("jump"):
			if is_on_floor():
				velocity.y = JUMP_VAL
		
	anim_tree.set("parameters/BlendSpace1D/blend_position",Vector2(velocity.x,velocity.z).length() / SPEED)

	move_and_slide()
