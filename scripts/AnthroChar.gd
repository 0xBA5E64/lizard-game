extends CharacterBody3D


const SPEED = 2.5
const JUMP_VELOCITY = 3.5
const JUMP_DELAY_TIME = 0.8

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var jumping = false
var jumpDelay = 0

var playerLookAt
var lastLookAtDirection : Vector3
var lastWalkDirection : Vector2

func _ready():
	playerLookAt = get_tree().get_nodes_in_group("CameraController")[0].get_node("PlayerLookAt")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jumping = true
		$AnimationTreeBlend.set("parameters/Jumping/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		jumpDelay = JUMP_DELAY_TIME
	if jumpDelay > 0:
		jumpDelay -= delta
	if jumpDelay <= 0 && jumping:
		velocity.y = JUMP_VELOCITY
		jumping = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		#Rotate the player towards the camera
		var lerpDirection = lerp(lastLookAtDirection, Vector3(playerLookAt.global_position.x, global_position.y, playerLookAt.global_position.z), 5 * delta)
		look_at(Vector3(lerpDirection.x, global_position.y, lerpDirection.z))
		lastLookAtDirection = lerpDirection
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	# Play the animation for the walking direction
	var walkLerpDirection = lerp(lastWalkDirection, Vector2(input_dir.x, -input_dir.y), 5 * delta)
	$AnimationTreeBlend.set("parameters/Walking/blend_position", walkLerpDirection)
	lastWalkDirection = walkLerpDirection
	
	move_and_slide()
