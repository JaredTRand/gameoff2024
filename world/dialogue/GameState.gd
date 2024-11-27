@tool
extends Node

var dialogue_on = false
var met_fish = false
var fish_introduction = false
var first_flake = false
@onready var phantom_cams
@onready var look_at:PhantomCamera3D

func _ready():
	phantom_cams = get_tree().get_nodes_in_group("phantomcams") 
	
func swap_camera(cam_to_switch_to:String):
	var new_cam 
	for cam in phantom_cams:
		if cam.get_meta("name") == cam_to_switch_to:
			new_cam = cam
			
	if new_cam && new_cam != look_at:
		if look_at: 
			look_at.priority = 10
		look_at = new_cam
		look_at.priority = 20
