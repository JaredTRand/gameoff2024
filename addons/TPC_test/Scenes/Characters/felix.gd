extends CharacterBody3D

const LERP_VALUE : float = 0.15

var snap_vector : Vector3 = Vector3.DOWN
var speed : float

var can_ledge_grab:bool = false

@export_group("Movement variables")
@export var walk_speed : float = 2.0
@export var run_speed : float = 5.0
@export var jump_strength : float = 15.0
@export var gravity : float = 50.0

const ANIMATION_BLEND : float = 7.0

@onready var player_mesh : Node3D = $felix
@onready var spring_arm_pivot : Node3D = $SpringArmPivot
@onready var animator : AnimationTree = $felix/AnimationTree

@onready var headcast:RayCast3D = $felix/Headcast
@onready var eyecast:RayCast3D  = $felix/Eyecast

@onready var move_direction : Vector3 = Vector3.ZERO
@onready var debug_panel = $UserInterface/DebugPanel

var jump_count:int = 0
var jump_count_max:int = 2

func _physics_process(delta):
	move_direction.x = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	move_direction.z = Input.get_action_strength("player_backward") - Input.get_action_strength("player_forward")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	velocity.y -= gravity * delta
	
	if Input.is_action_pressed("player_sprint"):
		speed = run_speed
	else:
		speed = walk_speed
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	
	if move_direction:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
		
	
	var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("player_jump")
	

	if is_jumping:
		jump_count += 1
		if jump_count <= 2:
			velocity.y = jump_strength
			snap_vector = Vector3.ZERO
	elif not is_on_floor() and Input.is_action_just_pressed("player_jump") and jump_count <= jump_count_max:
		velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		jump_count = 0
		snap_vector = Vector3.DOWN
	debug_panel.add_property("jump_count", jump_count)
	debug_panel.add_property("velocity", velocity)
	apply_floor_snap()
	move_and_slide()
	animate(delta)
	_process_raycasts()


func animate(delta):
	if is_on_floor():
		animator.set("parameters/ground_air_transition/transition_request", "grounded")
		
		if velocity.length() > 0:
			if speed == run_speed:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
			else:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
		else:
			animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
	else:
		animator.set("parameters/ground_air_transition/transition_request", "air")
		
		if velocity.y > 0:
			animator.set("parameters/jf_blend/blend_amount", lerp(animator.get("parameters/jf_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
		else:
			animator.set("parameters/jf_blend/blend_amount", lerp(animator.get("parameters/jf_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))



func _process_raycasts():
	var can_ledge_grab = not headcast.is_colliding() and eyecast.is_colliding()

func _on_interact_area_body_entered(body):
	if not body.is_in_group("interactable"): return
	debug_panel.add_property("interacting", true)
	body.interact_with_on()


func _on_interact_area_body_exited(body):
	if not body.is_in_group("interactable"): return
	debug_panel.add_property("interacting", false)
	body.interact_with_off()
