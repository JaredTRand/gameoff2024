extends CharacterBody3D

const LERP_VALUE : float = 0.15

var snap_vector : Vector3 = Vector3.DOWN
var speed : float
var can_interact:bool = false
var can_ledge_grab:bool = false

@export_group("Movement variables")
@export var walk_speed : float = 2.0
@export var run_speed : float = 5.0
@export var jump_strength : float = 15.0
@export var gravity : float = 50.0

@export_group("Camera variables")
@export var mouse_sensitivity: float = 0.05
@export var min_pitch: float = -89.9
@export var max_pitch: float = 50
@export var min_yaw: float = 0
@export var max_yaw: float = 360
@export var scroll_mult:float = .1
@export var scroll_max:float = 10
@export var scroll_min:float = 2


const ANIMATION_BLEND : float = 7.0

@onready var player_mesh : Node3D = $felix
@onready var animator : AnimationTree = $felix/AnimationTree

@onready var headcast:RayCast3D = $felix/Headcast
@onready var eyecast:RayCast3D  = $felix/Eyecast

@onready var move_direction : Vector3 = Vector3.ZERO

@onready var thought_bubble = $thought_bubble

@onready var hotbar = %UserInterface/HotBar
@onready var debug_panel = $UserInterface/DebugPanel
@onready var sounds:AudioStreamPlayer3D = $felix/sounds

@onready var _player_pcam: PhantomCamera3D

@onready var dust_effect:GPUParticles3D = $felix/dust_effect

var jump_count:int = 0
var jump_count_max:int = 1
var was_on_floor:bool = true

var cur_interactable_obj
var pre_pos

func _ready():
	_player_pcam = owner.get_node("%PlayerPhantomCamera3D")
	
	if _player_pcam.get_follow_mode() == _player_pcam.FollowMode.THIRD_PERSON:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if is_instance_valid(_player_pcam):
			_set_pcam_rotation(_player_pcam, event)
			
	var sp_length = _player_pcam.spring_length
	if Input.is_action_just_pressed("camera_zoom_in") and sp_length > scroll_min:
		_player_pcam.spring_length -= scroll_mult
	if Input.is_action_just_pressed("camera_zoom_out") and sp_length < scroll_max:
		_player_pcam.spring_length += scroll_mult

func _set_pcam_rotation(pcam: PhantomCamera3D, event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3

		# Assigns the current 3D rotation of the SpringArm3D node - so it starts off where it is in the editor
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()

		# Change the X rotation
		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity

		# Clamp the rotation in the X axis so it go over or under the target
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)

		# Change the Y rotation value
		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity

		# Sets the rotation to fully loop around its target, but witout going below or exceeding 0 and 360 degrees respectively
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)

		# Change the SpringArm3D node's rotation and rotate around its target
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)
	elif event is InputEventJoypadMotion:
		var pcam_rotation_degrees: Vector3
		
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
		pcam_rotation_degrees.x -= (event.get_action_strength("player_controller_camera_down") - event.get_action_strength("player_controller_camera_up")) * mouse_sensitivity*100
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)
		pcam_rotation_degrees.y -= (event.get_action_strength("player_controller_camera_right") - event.get_action_strength("player_controller_camera_left")) * mouse_sensitivity*100
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)

func _physics_process(delta):
	if GameState.dialogue_on:
		move_direction.x = 0
		move_direction.z = 0
		move_direction = move_direction.rotated(Vector3.UP, _player_pcam._follow_spring_arm.rotation.y)
		
		velocity.y -= gravity * delta
		velocity.x = move_direction.normalized().x 
		velocity.z = move_direction.normalized().z
		
		if move_direction:
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
		
		apply_floor_snap()
		move_and_slide()
		animate(delta)
		_process_raycasts()
	else:
		move_direction.x = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
		move_direction.z = Input.get_action_strength("player_backward") - Input.get_action_strength("player_forward")
		move_direction = move_direction.rotated(Vector3.UP, _player_pcam._follow_spring_arm.rotation.y)
	
		velocity.y -= gravity * delta
		
		if Input.is_action_pressed("player_sprint"):
			speed = run_speed
		else:
			speed = walk_speed
		
		velocity.x = move_direction.normalized().x * speed
		velocity.z = move_direction.normalized().z * speed
		
		if move_direction:
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
			
		if Input.is_action_just_pressed("player_interact"):
			if cur_interactable_obj:
				cur_interactable_obj.interact()
				cur_interactable_obj = null
			
		var just_landed := is_on_floor() and not was_on_floor #snap_vector == Vector3.ZERO
		var is_jumping := is_on_floor() and Input.is_action_just_pressed("player_jump")
		was_on_floor = is_on_floor()
		
		if is_jumping:
			jump_count += 1
			if jump_count <= jump_count_max:
				play_sound(load("res://world/sounds/felixjump.wav"))
				velocity.y = jump_strength
				snap_vector = Vector3.ZERO
		elif not is_on_floor() and Input.is_action_just_pressed("player_jump") and jump_count <= jump_count_max:
			play_sound(load("res://world/sounds/felixdoublejump.wav"))
			jump_count += 1
			dust_effect.restart()
			velocity.y = jump_strength
			snap_vector = Vector3.ZERO
		#elif not is_on_floor() and jump_count == 0:
			#jump_count += 1
		elif just_landed:
			debug_panel.add_property("last y speed", (global_position.y - pre_pos.y))
			if (global_position.y - pre_pos.y) < -.15:
				dust_effect.restart()
				play_sound(load("res://world/sounds/felixlandhard.wav"))
			play_sound(load("res://world/sounds/felixland.wav"), false)
			jump_count = 0
			snap_vector = Vector3.DOWN
			
		debug_panel.add_property("jump_count", jump_count)
		debug_panel.add_property("velocity", velocity)
		if pre_pos:
			debug_panel.add_property("speed!", (global_position - pre_pos).length())
		pre_pos = global_position
		apply_floor_snap()
		move_and_slide()
		animate(delta)
		_process_raycasts()

func play_sound(soundFile:AudioStreamWAV, interrupt:bool=true):
	if not interrupt and sounds.is_playing(): return
	
	sounds.stream = soundFile
	sounds.play()
	
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
		#do some checks here to make the double jump better.
		# check if animation is finished before moving to the fall animation
		if velocity.y > 0:
			if jump_count == 1:
				animator.set("parameters/jf_blend/blend_amount", lerp(animator.get("parameters/jf_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
			elif jump_count >= 2:
				animator.set("parameters/jf_blend/blend_amount", lerp(animator.get("parameters/jf_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
		else:
			animator.set("parameters/jf_blend/blend_amount", lerp(animator.get("parameters/jf_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))

func think(thought):
	thought_bubble.think(thought)

func _process_raycasts():
	var can_ledge_grab = not headcast.is_colliding() and eyecast.is_colliding()

func is_valid_interactable(body):
	if not body.is_in_group("interactable"):
		return false
	if not body.get_parent().has_method("interact"):
		return false
	if not body.get_parent().check_is_active():
		return false
	return true

func _on_interact_area_body_entered(body):
	if not is_valid_interactable(body): return
	
	debug_panel.add_property("interacting", true)
	can_interact = true
	body.get_parent().interact_with_on()
	
	if body.get_parent().is_active or body.get_parent().interaction_name == "Ferdinand" or body.get_parent().openable or body.get_parent().pickup_able:
		if cur_interactable_obj:
			_on_interact_area_body_exited(cur_interactable_obj)
		cur_interactable_obj = body.get_parent()


func _on_interact_area_body_exited(body):
	if not is_valid_interactable(body): return
	
	debug_panel.add_property("interacting", false)
	can_interact = false
	body.get_parent().interact_with_off()
	cur_interactable_obj = null
