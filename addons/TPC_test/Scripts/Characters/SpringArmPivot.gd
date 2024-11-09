extends Node3D

@export var scroll_max : float = 7.5
@export var scroll_min : float = 1.0
@export var scroll_inter : float = 0.1

@export_group("FOV")
@export var change_fov_on_run : bool
@export var normal_fov : float = 75.0
@export var run_fov : float = 90.0

const CAMERA_BLEND : float = 0.05

@onready var spring_arm : SpringArm3D = $SpringArm3D
@onready var camera : Camera3D = $SpringArm3D/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	_process_springarm_scroll()
		
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		spring_arm.rotate_x(-event.relative.y * 0.005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)

func _process_springarm_scroll():
	if Input.is_action_just_pressed("camera_zoom_in"):
		if spring_arm.spring_length > scroll_min:
			spring_arm.spring_length -= scroll_inter
	elif Input.is_action_just_pressed("camera_zoom_out"):
		if spring_arm.spring_length < scroll_max:
			spring_arm.spring_length += scroll_inter
	

func _physics_process(_delta):
	if change_fov_on_run:
		if owner.is_on_floor():
			if Input.is_action_pressed("run"):
				camera.fov = lerp(camera.fov, run_fov, CAMERA_BLEND)
			else:
				camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)
		else:
			camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)
